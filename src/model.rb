require 'visitable'

StartTest = Struct.new(:testClassName, :testName) do
  include Visitable
end

FinishTest = Struct.new(:testClassName, :testName) do
  include Visitable
end

HttpRequest = Struct.new(:source_name, :destination_name, :method, :path, :body, :cookie_header, :content_type_header) do
  include Visitable
end

HttpResponse = Struct.new(:source_name, :destination_name, :response_code, :set_cookie_header, :location_header, :content_type_header, :body) do
  include Visitable
end
