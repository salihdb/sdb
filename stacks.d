module sdb.stacks;

/****************************************************/
  class Stack(T) {
/****************************************************/
    int index;
    T[] stack;
                              /* #s1: */
    void push (T data) @property {
        stack ~= data;
        this.index++;
    }
                              /* #s2: */ 
    T pop () @property {
        return stack[--this.index];
    }
                              /* #s3: */
    int size () @property {
        return this.index;
    }
                              /* #s4: */
    bool empty () const @property {
        return this.index == 0;
    }

} unittest { /* Class Stack Tests */

    auto myStack = new Stack!int;
    int sum, i = 11;

    foreach(data; 0..i) {
        myStack.push(data);     // #s1.
    }
    assert (i == myStack.size); // #s3.

    while(!myStack.empty()) {   // #s4.
        sum += myStack.pop();   // #s2.
    }
    assert (sum == 55);

    assert (myStack.size == 0);
}

/****************************************************/
  class BoolStack(T) : Stack!T {
/****************************************************/
  public:
/***********/
    immutable length_t = (T.sizeof * 8);

    this (size_t size) {
        size_t lenOverflow = size % length_t ? 1 : 0;
        super.stack = new T[(size / length_t) + lenOverflow];
    }
                              /* #b1: */
    void clear () @property {
        //stack = stack.init; stack.length = super.index;/*
        foreach(ref cell; stack) {
            cell = 0;
        }//*/
        super.index = 0;
    }
                              /* #b2: */
    auto length () const @property {
        return (stack.length * T.sizeof) + index.sizeof;
    }

  private
/***********/
    bool bitTest (size_t bit) {
        T xCell = stack[bit / length_t];
        T xMask = cast(T)1 << bit % length_t;

        return (xCell & xMask) != 0;
    }

  override:
/***********/
                              /* #b3: */
    void push (T data) @property {
        immutable index = super.index / length_t;
        immutable xMask = super.index % length_t;
        
        if(index >= stack.length) {
            throw new Exception("Stack is full!");
        }
        stack[index] |= data << xMask;
        super.index++;
    }
                              /* #b4: */
    T pop () @property {
        if(!super.index) {
            throw new Exception("Stack is empty!");
        }
        return cast(T)bitTest(--super.index);
    }
                              /* #b5: */
    string toString () @property { 
        string result = "[";
        foreach(i; 0..super.index) {
            result ~= bitTest(i) ? "1" : "0";
        }
        return result ~ "]";     
    }

} unittest { /* Class BoolStack Tests */

    auto data = [ false, true, false, false, true, false, true, true,
                  true ]; //<-- 2/1 byte ---------------------------^
    auto test = new BoolStack!ubyte(data.length);
    // 4(int) + 2(ubyte) = 6
    assert (test.length == 6 ); // #b2.

    assert (test.empty);        // #s4.

    test.push (false);
    assert (!test.empty);

    test.push (true);
    assert (test.size == 2);    // #s3.

    test.clear;                 // #b1.
    assert (test.empty);
    
    foreach(d; data) {
        test.push(d);           // #b3.
    }
    assert(!test.empty);

    assert(test.toString ==
           "[010010111]");      // #b5.

    foreach_reverse(d; data) {
        assert(d == test.pop);  // #b4.
    }
    assert(test.empty);
}

/* Not been tested yet. */

class ExpStack (T) : Stack!T {
    T temp;

    ref T top() @property {
        return stack[super.index - 1];
    }
    
    ref T first() @property {
        return stack[0];
    }
    
    T topBackup(bool refresh = true) {
        if(refresh) this.temp = pop;
        return this.temp;  
    } 

    void popFront() @property {
        --super.index;
    }
    
    T front() const @property {
      return stack[super.index - 1];
    }
    
    void clear() @property {
        stack = stack.init;
        if(stack.length) {
            throw new Exception("Stack is not empty!");
        } else super.index = 0;
    } 

}

debug void main() {
/* Compile parameters:
 * dmd sdb.stacks.d -debug -unittest
 */
}