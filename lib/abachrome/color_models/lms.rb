# Abachrome::ColorModels::Lms - LMS color space model definition
#
# This module defines the LMS color model within the Abachrome color manipulation library.
# LMS represents the response of the three types of cone cells in the human eye (Long, Medium, Short)
# and serves as an intermediate color space in the OKLAB transformation pipeline. The LMS color space
# provides a foundation for perceptually uniform color representations by modeling human visual perception
# at the photoreceptor level.
#
# Key features:
# - Registers the LMS color space with coordinate names [l, m, s]
# - Represents cone cell responses for Long, Medium, and Short wavelength sensitivity
# - Serves as intermediate color space for OKLAB and linear RGB conversions
# - Uses normalized values for consistency with other color models in the library
# - Maintains high precision through AbcDecimal arithmetic for color transformations
# - Provides validation for LMS coordinate ranges to ensure valid color representations
#
# The LMS model is particularly important in the color science pipeline as it bridges the gap
# between linear RGB representations and perceptually uniform color spaces like OKLAB, enabling
# accurate color transformations that better match human visual perception characteristics.

module Abachrome
  module ColorModels
    class Lms
    end
  end
end

ColorSpace.register(
  :lms,
  "LMS",
  %w[l m s],
  nil,
  []
)
