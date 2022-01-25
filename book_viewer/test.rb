def first(param)
  puts param
end

def second(param)
  puts param
end

def third(param)
  puts param
end

def fourth(param)
  puts param
end

fourth(third(second(first("Something I want to output to the console."))))

fourth third second first "Something I want to print"