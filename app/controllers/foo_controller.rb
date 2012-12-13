class FooController < ApplicationController
  def bar
    render text: "foobarbaz: #{current_user.email}"
  end
end