class Base < ActiveJob::Base
  def exec_job(&_block)
    yield
  end
end
