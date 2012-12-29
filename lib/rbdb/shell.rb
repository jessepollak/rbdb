require 'socket'
require 'rbdb/db'

module RBDB
    class Shell

        OPTIONS = {
            port: 1121,
            host: 'localhost',
            binding: TOPLEVEL_BINDING
        }

        def initialize
            @binding = OPTIONS[:binding]
            @binding.eval("db = RBDB::DB.new")

            trap("INT") { shutdown }
            start!
        end

        private

            def start!
                catch { loop_once while true }
            end

            def loop_once
                prompt
                get_input
                eval_input
                put_output
            end

            def get_input
                @input = gets
            end

            def put_output
                if !@error
                    puts @result
                else
                    put_error(@error)
                    @error = nil
                end
            end

            def prompt
                print "rbdb>> "
            end

            def eval_input
                @result = eval(@input, @binding)
            rescue Exception => e
                @error = e
            end

            def put_error(err)
                puts format_error(err)
            end

            def format_error(err)
                stack = err.backtrace.take_while {|line| line !~ %r{/rbdb/\S+\.rb} }
                "#{err.class}: #{err.message}#{$/}    #{stack.join("#{$/}    ")}"
            end

            def shutdown
                puts
                exit!
            end
    end
end
