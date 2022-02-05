def list_complete?(list)
  finished = todos_finished(list)
  !finished.zero? && (list[:todos].size == finished)
end

def sort_lists(lists)
  # return a hash with lists as keys, and indices as values.
  display_order = Hash.new

  lists.each_with_index do |list, index|
    display_order[list] = index
  end

  new = display_order.sort_by { |list, idx| list_complete?(list) ? 1 : 0 }
  yield(new) if block_given?
end
