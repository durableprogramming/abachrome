#

module Abachrome
  module Illuminants
    class Base
      class << self
        def whitepoint
          raise NotImplementedError, "#{name}#whitepoint must be implemented"
        end

        def x
          whitepoint[0]
        end

        def y
          whitepoint[1]
        end

        def z
          whitepoint[2]
        end

        def xyz
          whitepoint
        end

        def to_s
          name.split("::").last
        end
      end
    end
  end
end