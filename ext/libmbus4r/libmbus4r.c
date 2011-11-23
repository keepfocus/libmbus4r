#include <ruby.h>

#include <mbus/mbus.h>

static VALUE rb_mLibMbus;
static VALUE rb_cLMFrame;

typedef struct _mbus_frame_and_data {
  mbus_frame *frame;
  mbus_frame_data *data;
} mbus_frame_and_data;

#define CSTR2SYM(s) ID2SYM(rb_intern(s))


static void mbus4r_frame_free(mbus_frame_and_data *p)
{
  if (p->data) {
    mbus_frame_data_free(p->data);
  }
  if (p->frame) {
    mbus_frame_free(p->frame);
  }
  free(p);
}

static VALUE mbus4r_frame_parse(VALUE class, VALUE buffer)
{
  mbus_frame *frame = mbus_frame_new(MBUS_FRAME_TYPE_ANY);
  mbus_frame_data *data = mbus_frame_data_new();
  mbus_frame_and_data *fd = malloc(sizeof(mbus_frame_and_data));

  mbus_parse(frame, RSTRING_PTR(buffer), RSTRING_LEN(buffer));
  mbus_frame_data_parse(frame, data);
  fd->frame = frame;
  fd->data = data;

  VALUE tdata = Data_Wrap_Struct(class, 0, mbus4r_frame_free, fd);
  return tdata;
}

static VALUE mbus4r_frame_to_xml(VALUE self)
{
  mbus_frame_and_data *fd = NULL;
  char *result;

  Data_Get_Struct(self, mbus_frame_and_data, fd);
  result = mbus_frame_data_xml(fd->data);
  return rb_str_new2(result);
}

static VALUE mbus4r_frame_serial(VALUE self)
{
  mbus_frame_and_data *fd;
  char *result;

  Data_Get_Struct(self, mbus_frame_and_data, fd);
  result = mbus_frame_get_secondary_address(fd->frame);
  return rb_str_new2(result);
}

static VALUE mbus4r_frame_data_fields(VALUE self)
{
  mbus_frame_and_data *fd;
  mbus_data_record *record;
  VALUE result = rb_ary_new();
  VALUE hash;
  mbus_record *mr;
  int i = 0;

  Data_Get_Struct(self, mbus_frame_and_data, fd);
  if (fd->data->type == MBUS_DATA_TYPE_VARIABLE) {
    record = fd->data->data_var.record;
    for (i = 0; record; record = record->next, i++) {
      hash = rb_hash_new();
      mr = mbus_parse_variable_record(record);
      if (mr) {
        if (mr->unit) {
          rb_hash_aset(hash, CSTR2SYM("unit"), rb_str_new2(mr->unit));
        }
        if (mr->quantity) {
          rb_hash_aset(hash, CSTR2SYM("quantity"), rb_str_new2(mr->quantity));
        }
        if (mr->is_numeric) {
          rb_hash_aset(hash, CSTR2SYM("value"), rb_float_new(mr->value.real_val));
        }
        if (mr->function_medium) {
          rb_hash_aset(hash, CSTR2SYM("function"), rb_str_new2(mr->function_medium));
        }
        else {
          rb_hash_aset(hash, CSTR2SYM("value"), rb_str_new(mr->value.str_val.value, mr->value.str_val.size));
        }
        mbus_record_free(mr);
      }
      else {
        rb_hash_aset(hash, CSTR2SYM("raw"), rb_str_new(record->data, record->data_len));
        rb_hash_aset(hash, CSTR2SYM("dib"), INT2FIX(record->drh.dib.dif));
        rb_hash_aset(hash, CSTR2SYM("vib"), INT2FIX(record->drh.vib.vif));
        rb_hash_aset(hash, CSTR2SYM("function"), rb_str_new2(mbus_data_record_function(record)));
        rb_hash_aset(hash, CSTR2SYM("unit"), rb_str_new2(mbus_vib_unit_lookup(&record->drh.vib)));
        rb_hash_aset(hash, CSTR2SYM("error"), rb_str_new2("Could not parse data record"));
      }
      rb_ary_push(result, rb_yield(hash));
    }
  }
  return result;
}

void Init_libmbus4r()
{
  rb_mLibMbus = rb_define_module("LibMbus");

  rb_cLMFrame = rb_define_class_under(rb_mLibMbus, "Frame", rb_cObject);
  rb_define_singleton_method(rb_cLMFrame, "parse", mbus4r_frame_parse, 1);
  rb_define_method(rb_cLMFrame, "to_xml", mbus4r_frame_to_xml, 0);
  rb_define_method(rb_cLMFrame, "serial", mbus4r_frame_serial, 0);
  rb_define_method(rb_cLMFrame, "map_data_fields", mbus4r_frame_data_fields, 0);
}
