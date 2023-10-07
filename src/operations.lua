local Op = {
  Add = function(valA, valB)
      if type(valA) == "string" or type(valB) == "string" then
          return tostring(valA) .. tostring(valB)
      end
      return valA + valB
  end,
  Sub = function(valA, valB)
      return valA - valB
  end,
  Mul = function(valA, valB)
      return valA * valB
  end,
  Div = function(valA, valB)
      if valB == 0 then
          return nil
      end
      if valA % valB == 0 then
          return valA / valB
      end
      return math.floor(valA / valB)
  end,
  Rem = function(valA, valB)
      return valA % valB
  end,
  Eq = function(valA, valB)
      return valA == valB
  end,
  Neq = function(valA, valB)
      return valA ~= valB
  end,
  Lt = function(valA, valB)
      return valA < valB
  end,
  Gt = function(valA, valB)
      return valA > valB
  end,
  Lte = function(valA, valB)
      return valA <= valB
  end,
  Gte = function(valA, valB)
      return valA >= valB
  end,
  And = function(valA, valB)
      return valA and valB
  end,
  Or = function(valA, valB)
      return valA or valB
  end,
}

return Op