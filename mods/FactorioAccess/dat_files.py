import struct
from collections import namedtuple
from typing import Type,Union,get_origin,get_args
import io

class dat_type(object):
    pass

class basic_type(dat_type):
    def __new__(cls,stream:io.BytesIO):
        length=struct.calcsize(cls.format)
        _bytes=stream.read(length)
        _val=struct.unpack(cls.format,_bytes)
        return super().__new__(cls,_val[0])
    
class u8(basic_type,int):
    format="<B"
class s8(basic_type,int):
    format="<b"
class u16(basic_type,int):
    format="<H"
class s16(basic_type,int):
    format="<H"
class u32(basic_type,int):
    format="<I"
class u32(basic_type,int):
    format="<i"
class f32(basic_type,int):
    format="<f"
class f64(basic_type,int):
    format="<d"

class count(dat_type,int):
    def __new__(cls,stream):
        val=u8(stream)
        if val==0xFF:
            val=u32(stream)
        return super().__new__(cls,val)
class count16(dat_type,int):
    def __new__(cls,stream):
        val=u8(stream)
        if val==0xFF:
            val=u16(stream)
        return super().__new__(cls,val)

class string(dat_type,str):
    def __new__(cls,stream):
        length=count(stream)
        return super().__new__(cls,stream.read(length).decode())

class struct_type(dat_type):
    def __init__(self,stream):
        for name,type_ in type(self).__annotations__.items():
            origin = get_origin(type_)
            val=None
            if origin:
                if issubclass(origin,list):
                    length = count(stream)
                    sub_type = get_args(type_)[0]
                    val=[sub_type(stream) for _ in range(length)]
            else:
                if not issubclass(type_,dat_type):
                    raise ValueError(f"Class {type(self)} has non-dat_type member {name} of type {type_}")
                val=type_(stream)
            self.__setattr__(name,val)

class version(struct_type):
    main:u16
    major:u16
    minor:u16
    release:u16

class mod_listing(struct_type):
    name:string
    major:count16
    minor:count16
    patch:count16
    crc:u32

class level_init(struct_type):
    ver:version
    unk1:u16
    senario:string
    senario_mod:string
    unk2:u32
    unk3:u32
    factorio_main:count
    factorio_major:count
    factorio_minor:count
    unk4:u16
    unk5:u8
    mods:list[mod_listing]


def simple_dat_class(cls:Type):
    for name,type in cls.__annotations__.items():
        if not issubclass(type,dat_type):
            raise ValueError(f"Class {cls} has non-dat_type member {name} of type {type}")
    return cls

@simple_dat_class
class dat_named_tuple(object):
    my_var:u8


if __name__ == "__main__":
    with open(r"C:\Users\frederick.doering\Downloads\level-init_2.dat","rb") as f:
        v = level_init(f)
        print("woot")
    print(dat_named_tuple.__annotations__)
    print(issubclass(u8,dat_type))
