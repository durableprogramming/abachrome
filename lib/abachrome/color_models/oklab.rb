# frozen_string_literal: true

module Abachrome
  module ColorModels
    class Oklab
    end
  end
end

ColorSpace.register(
  :oklab,
  "Oklab",
  %w[l a b],
  nil,
  ["ok-lab"]
)
