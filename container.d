module sdb.container;

    union parçala {
      ulong data;
      ubyte[8] p8b;
      ushort[4] p4s;
      uint[2] p2i;
    }

struct Tx {
    parçala veri;
    size_t dizin;
 
    TypeInfo tür = typeid(ulong); // fixed a
    
    this(T)(T değeri) {
      this.dizin = 1;  // artık ilk eleman 1...:)
      this.veri = parçala(
              cast(ulong)değeri); 
      this.tür = typeid(T); // boş kurulmamalı (a)
    }
    
    void popFront() {
      dizin = empty() ? 0 : dizin + 1;
    }
    
    @property
    bool empty() const {
      return (dizin > tür.tsize());
    }
 
    @property
    ulong front() const {
      return dizin ? part(dizin) : veri.data;
    }
    
    @property
    ubyte part(size_t i) const
    in { assert(i, "0 alamaz!"); } body {
      return i > tür.tsize() ? 0 : veri.p8b[i - 1];
    }

    T to(T)() {
      switch(T.sizeof) {
        case 1: return cast(T)veri.p8b[0];
        case 2: return cast(T)veri.p4s[0];
        case 4: return cast(T)veri.p2i[0];
        default:
      }
      return cast(T)veri.data;
    }
}