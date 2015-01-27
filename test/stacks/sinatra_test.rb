module Deployinator

  module Helpers
    module SinatraTestHelpers

    end
  end
end


module Deployinator
  module Stacks
    class SinatraTestDeploy < Deployinator::Deploy
      include Deployinator::Helpers::SinatraTestHelpers,
        Deployinator::Helpers::GitHelpers

      def sinatra_test_production(options = {})
        log_and_stream "THIS IS THE STACK BEING RUN"
        log_and_stream "This is coming from inside the stack"
      end

    end
  end
end
