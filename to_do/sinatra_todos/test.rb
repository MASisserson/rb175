list = {
  name: 'hoopla',
  todos: [
    { name: 'homework', complete: false },
    { name: 'groceries', complete: true }
  ]
}

var = list[:todos].inject(0) do |sum, todo|
  if todo[:complete]
    sum += 1
  else
    sum
  end
end

p var
