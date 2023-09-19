# Performance test using

# Scenarios

- Execution of `run.sh` using Lua and LuaJIT
- AST used in tests
  - print
  - fib - 30
  - sum
  - combination

## LuaJIT

- Test 1

  - real 0m16,425s
  - user 0m16,385s
  - sys 0m0,004s

- Test 2

  - real 0m15,232s
  - user 0m15,207s
  - sys 0m0,008s

## Lua

- Test 1

  - real 0m15,930s
  - user 0m15,925s
  - sys 0m0,004s

- Test 2

  - real 0m15,509s
  - user 0m15,507s
  - sys 0m0,000s
