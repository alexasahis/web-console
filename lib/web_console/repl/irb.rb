require 'irb'
require 'irb/frame'
require 'stringio'
require 'active_support/core_ext/module/delegation'

module WebConsole
  module REPL
    # == IRB\ Adapter
    #
    # Adapter for the IRB REPL, which is the default Ruby on Rails console.
    class IRB
      class StringIOInputMethod < ::IRB::InputMethod
        def inititalize(io)
          @io = io
        end

        delegate :eof?, :gets, to: :@io
      end

      def initialize(binding = ::IRB::Frame.top(1))
        initialize_irb_session!
        @input = StringIO.new
        @irb   = ::IRB::Irb.new(::IRB::WorkSpace.new(binding), StringIOInputMethod.new(@input))
      end

      def send_input(input)
        replace_input!(input)
        @irb.eval_input
      end

      delegate :prompt, to: :@input

      private
        def initialize_irb_session!(ap_path = nil)
          ::IRB.init_config(ap_path)
          ::IRB.init_error
        end

        def replace_input!(input)
          # The rewinds are important here. StringIO#truncate will nullify the
          # underlying string, but won't change the current position. Therefore,
          # the next write may be preceeded by leading +\u0000+ characters.
          @input.truncate(0)
          @input.rewind
          @input.write(input)
          @input.rewind
        end
    end

    register_adapter IRB
  end
end
