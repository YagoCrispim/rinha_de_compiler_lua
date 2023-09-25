# lua-rinha-interpreter

An interpreter for ".rinha" files. Made for "Rinha de Compiladores" using Lua

## Files

✅ fib <br/>
✅ combination <br/>
✅ sum <br/>
✅ print <br/>
✅ first <br/>
✅ second <br/>
✅ sub <br/>
✅ print_tuple <br/>
✅ print_function <br/>
✅ concate

## Docker

### Build

```bash
docker build -t rinha-de-compiler-lua .
```

### Run

```bash
docker run -v ./asts/{{FILE_NAME}}:/var/rinha/source.rinha.json --memory=2gb --cpus=2 rinha-de-compiler-lua
```
