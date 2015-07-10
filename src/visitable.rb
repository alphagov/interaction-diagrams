module Visitable

  def accept(processor)
    method_name="visit_#{self.class}"
    processor.send(method_name, self)
  end

end


class DoNothing
  def accept(e)
  end
end
