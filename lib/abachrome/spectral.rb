# Abachrome::Spectral - Kubelka-Munk spectral color mixing
#
# This module implements the Kubelka-Munk theory for realistic paint-like color mixing.
# Based on spectral.js by Ronald van Wijnen (https://github.com/rvanwijnen/spectral.js)
#
# The Kubelka-Munk model simulates how real pigments absorb and scatter light by:
# 1. Converting RGB colors to spectral reflectance curves (38 wavelength samples)
# 2. Computing absorption/scattering coefficients (KS values)
# 3. Mixing colors by weighted averaging of KS values
# 4. Converting back to RGB via XYZ color space
#
# This produces more realistic color mixing than simple RGB interpolation,
# avoiding issues like muddy browns when mixing complementary colors.

require_relative "abc_decimal"

module Abachrome
  module Spectral
    module_function

    # Number of wavelength samples in spectral curves
    SIZE = 38

    # Gamma value for sRGB companding
    GAMMA = 2.4

    # Base spectral reflectance curves for White, Cyan, Magenta, Yellow, Red, Green, Blue
    # These are the fundamental building blocks for converting RGB to spectral data
    BASE_SPECTRA = {
      W: [
        1.00116072718764, 1.00116065159728, 1.00116031922747, 1.00115867270789, 1.00115259844552, 1.00113252528998, 1.00108500663327, 1.00099687889453, 1.00086525152274,
        1.0006962900094, 1.00050496114888, 1.00030808187992, 1.00011966602013, 0.999952765968407, 0.999821836899297, 0.999738609557593, 0.999709551639612, 0.999731930210627,
        0.999799436346195, 0.999900330316671, 1.00002040652611, 1.00014478793658, 1.00025997903412, 1.00035579697089, 1.00042753780269, 1.00047623344888, 1.00050720967508,
        1.00052519156373, 1.00053509606896, 1.00054022097482, 1.00054272816784, 1.00054389569087, 1.00054448212151, 1.00054476959992, 1.00054489887762, 1.00054496254689,
        1.00054498927058, 1.000544996993
      ].freeze,
      C: [
        0.970585001322962, 0.970592498143425, 0.970625348729891, 0.970786806119017, 0.971368673228248, 0.973163230621252, 0.976740223158765, 0.981587605491377, 0.986280265652949,
        0.989949147689134, 0.99249270153842, 0.994145680405256, 0.995183975033212, 0.995756750110818, 0.99591281828671, 0.995606157834528, 0.994597600961854, 0.99221571549237,
        0.986236452783249, 0.967943337264541, 0.891285004244943, 0.536202477862053, 0.154108119001878, 0.0574575093228929, 0.0315349873107007, 0.0222633920086335, 0.0182022841492439,
        0.016299055973264, 0.0153656239334613, 0.0149111568733976, 0.0146954339898235, 0.0145964146717719, 0.0145470156699655, 0.0145228771899495, 0.0145120341118965,
        0.0145066940939832, 0.0145044507314479, 0.0145038009464639
      ].freeze,
      M: [
        0.990673557319988, 0.990671524961979, 0.990662582353421, 0.990618107644795, 0.99045148087871, 0.989871081400204, 0.98828660875964, 0.984290692797504, 0.973934905625306,
        0.941817838460145, 0.817390326195156, 0.432472805065729, 0.13845397825887, 0.0537347216940033, 0.0292174996673231, 0.021313651750859, 0.0201349530181136, 0.0241323096280662,
        0.0372236145223627, 0.0760506552706601, 0.205375471942399, 0.541268903460439, 0.815841685086486, 0.912817704123976, 0.946339830166962, 0.959927696331991, 0.966260595230312,
        0.969325970058424, 0.970854536721399, 0.971605066528128, 0.971962769757392, 0.972127272274509, 0.972209417745812, 0.972249577678424, 0.972267621998742, 0.97227650946215,
        0.972280243306874, 0.97228132482656
      ].freeze,
      Y: [
        0.0210523371789306, 0.0210564627517414, 0.0210746178695038, 0.0211649058448753, 0.0215027957272504, 0.0226738799041561, 0.0258235649693629, 0.0334879385639851,
        0.0519069663740307, 0.100749014833473, 0.239129899706847, 0.534804312272748, 0.79780757864303, 0.911449894067384, 0.953797963004507, 0.971241615465429, 0.979303123807588,
        0.983380119507575, 0.985461246567755, 0.986435046976605, 0.986738250670141, 0.986617882445032, 0.986277776758643, 0.985860592444056, 0.98547492767621, 0.985176934765558,
        0.984971574014181, 0.984846303415712, 0.984775351811199, 0.984738066625265, 0.984719648311765, 0.984711023391939, 0.984706683300676, 0.984704554393091, 0.98470359630937,
        0.984703124077552, 0.98470292561509, 0.984702868122795
      ].freeze,
      R: [
        0.0315605737777207, 0.0315520718330149, 0.0315148215513658, 0.0313318044982702, 0.0306729857725527, 0.0286480476989607, 0.0246450407045709, 0.0192960753663651,
        0.0142066612220556, 0.0102942608878609, 0.0076191460521811, 0.005898041083542, 0.0048233247781713, 0.0042298748350633, 0.0040599171299341, 0.0043533695594676,
        0.0053434425970201, 0.0076917201010463, 0.0135969795736536, 0.0316975442661115, 0.107861196355249, 0.463812603168704, 0.847055405272011, 0.943185409393918, 0.968862150696558,
        0.978030667473603, 0.982043643854306, 0.983923623718707, 0.984845484154382, 0.985294275814596, 0.985507295219825, 0.985605071539837, 0.985653849933578, 0.985677685033883,
        0.985688391806122, 0.985693664690031, 0.985695879848205, 0.985696521463762
      ].freeze,
      G: [
        0.0095560747554212, 0.0095581580120851, 0.0095673245444588, 0.0096129126297349, 0.0097837090401843, 0.010378622705871, 0.0120026452378567, 0.0160977721473922,
        0.026706190223168, 0.0595555440185881, 0.186039826532826, 0.570579820116159, 0.861467768400292, 0.945879089767658, 0.970465486474305, 0.97841363028445, 0.979589031411224,
        0.975533536908632, 0.962288755397813, 0.92312157451312, 0.793434018943111, 0.459270135902429, 0.185574103666303, 0.0881774959955372, 0.05436302287667, 0.0406288447060719,
        0.034221520431697, 0.0311185790956966, 0.0295708898336134, 0.0288108739348928, 0.0284486271324597, 0.0282820301724731, 0.0281988376490237, 0.0281581655342037,
        0.0281398910216386, 0.0281308901665811, 0.0281271086805816, 0.0281260133612096
      ].freeze,
      B: [
        0.979404752502014, 0.97940070684313, 0.979382903470261, 0.979294364945594, 0.97896301460857, 0.977814466694043, 0.974724321133836, 0.967198482343973, 0.949079657530575,
        0.900850128940977, 0.76315044546224, 0.465922171649319, 0.201263280451005, 0.0877524413419623, 0.0457176793291679, 0.0284706050521843, 0.020527176756985, 0.0165302792310211,
        0.0145135107212858, 0.0136003508637687, 0.0133604258769571, 0.013548894314568, 0.0139594356366992, 0.014443425575357, 0.0148854440621406, 0.0152254296999746,
        0.0154592848180209, 0.0156018026485961, 0.0156824871281936, 0.0157248764360615, 0.0157458108784121, 0.0157556123350225, 0.0157605443964911, 0.0157629637515278,
        0.0157640525629106, 0.015764589232951, 0.0157648147772649, 0.0157648801149616
      ].freeze
    }.freeze

    # CIE 1931 Color Matching Functions weighted by D65 Standard Illuminant
    # Used to convert spectral reflectance to XYZ tristimulus values
    CMF = [
      [
        0.0000646919989576, 0.0002194098998132, 0.0011205743509343, 0.0037666134117111, 0.011880553603799, 0.0232864424191771, 0.0345594181969747, 0.0372237901162006,
        0.0324183761091486, 0.021233205609381, 0.0104909907685421, 0.0032958375797931, 0.0005070351633801, 0.0009486742057141, 0.0062737180998318, 0.0168646241897775,
        0.028689649025981, 0.0426748124691731, 0.0562547481311377, 0.0694703972677158, 0.0830531516998291, 0.0861260963002257, 0.0904661376847769, 0.0850038650591277,
        0.0709066691074488, 0.0506288916373645, 0.035473961885264, 0.0214682102597065, 0.0125164567619117, 0.0068045816390165, 0.0034645657946526, 0.0014976097506959,
        0.000769700480928, 0.0004073680581315, 0.0001690104031614, 0.0000952245150365, 0.0000490309872958, 0.0000199961492222
      ].freeze,
      [
        0.000001844289444, 0.0000062053235865, 0.0000310096046799, 0.0001047483849269, 0.0003536405299538, 0.0009514714056444, 0.0022822631748318, 0.004207329043473,
        0.0066887983719014, 0.0098883960193565, 0.0152494514496311, 0.0214183109449723, 0.0334229301575068, 0.0513100134918512, 0.070402083939949, 0.0878387072603517,
        0.0942490536184085, 0.0979566702718931, 0.0941521856862608, 0.0867810237486753, 0.0788565338632013, 0.0635267026203555, 0.05374141675682, 0.042646064357412,
        0.0316173492792708, 0.020885205921391, 0.0138601101360152, 0.0081026402038399, 0.004630102258803, 0.0024913800051319, 0.0012593033677378, 0.000541646522168,
        0.0002779528920067, 0.0001471080673854, 0.0000610327472927, 0.0000343873229523, 0.0000177059860053, 0.000007220974913
      ].freeze,
      [
        0.000305017147638, 0.0010368066663574, 0.0053131363323992, 0.0179543925899536, 0.0570775815345485, 0.113651618936287, 0.17335872618355, 0.196206575558657,
        0.186082370706296, 0.139950475383207, 0.0891745294268649, 0.0478962113517075, 0.0281456253957952, 0.0161376622950514, 0.0077591019215214, 0.0042961483736618,
        0.0020055092122156, 0.0008614711098802, 0.0003690387177652, 0.0001914287288574, 0.0001495555858975, 0.0000923109285104, 0.0000681349182337, 0.0000288263655696,
        0.0000157671820553, 0.0000039406041027, 0.000001584012587, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
      ].freeze
    ].freeze

    # sRGB to XYZ transformation matrix (D65 illuminant)
    RGB_TO_XYZ = [
      [0.41239079926595934, 0.357584339383878, 0.1804807884018343],
      [0.21263900587151027, 0.715168678767756, 0.07219231536073371],
      [0.01933081871559182, 0.11919477979462598, 0.9505321522496607]
    ].freeze

    # XYZ to sRGB transformation matrix (D65 illuminant)
    XYZ_TO_RGB = [
      [3.2409699419045226, -1.537383177570094, -0.4986107602930034],
      [-0.9692436362808796, 1.8759675015077202, 0.04155505740717559],
      [0.05563007969699366, -0.20397695888897652, 1.0569715142428786]
    ].freeze

    # Inverse companding: sRGB to linear RGB
    def uncompand(x)
      x = x.to_f
      x > 0.04045 ? ((x + 0.055) / 1.055)**GAMMA : x / 12.92
    end

    # Companding: linear RGB to sRGB
    def compand(x)
      x = x.to_f
      x > 0.0031308 ? 1.055 * x**(1.0 / GAMMA) - 0.055 : x * 12.92
    end

    # Convert sRGB [0-1] to linear RGB
    def srgb_to_lrgb(srgb)
      srgb.map { |x| uncompand(x) }
    end

    # Convert linear RGB to sRGB [0-1]
    def lrgb_to_srgb(lrgb)
      lrgb.map { |x| compand(x) }
    end

    # Matrix-vector multiplication
    def mul_mat_vec(matrix, vector)
      matrix.map do |row|
        row.zip(vector).map { |a, b| a * b }.sum
      end
    end

    # Convert linear RGB to spectral reflectance curve
    # Uses the seven primary spectral curves (W, C, M, Y, R, G, B)
    def lrgb_to_reflectance(lrgb)
      r, g, b = lrgb

      # Extract white component
      w = [r, g, b].min
      r, g, b = r - w, g - w, b - w

      # Extract CMY components
      c = [g, b].min
      m = [r, b].min
      y = [r, g].min

      # Extract pure RGB components
      r_pure = [0, [r - b, r - g].min].max
      g_pure = [0, [g - b, g - r].min].max
      b_pure = [0, [b - g, b - r].min].max

      # Combine spectral curves
      reflectance = Array.new(SIZE) do |i|
        [
          Float::EPSILON,
          w * BASE_SPECTRA[:W][i] +
          c * BASE_SPECTRA[:C][i] +
          m * BASE_SPECTRA[:M][i] +
          y * BASE_SPECTRA[:Y][i] +
          r_pure * BASE_SPECTRA[:R][i] +
          g_pure * BASE_SPECTRA[:G][i] +
          b_pure * BASE_SPECTRA[:B][i]
        ].max
      end

      reflectance
    end

    # Convert spectral reflectance to XYZ using CIE color matching functions
    def reflectance_to_xyz(reflectance)
      mul_mat_vec(CMF, reflectance)
    end

    # Convert XYZ to linear RGB
    def xyz_to_lrgb(xyz)
      mul_mat_vec(XYZ_TO_RGB, xyz)
    end

    # Convert linear RGB to XYZ
    def lrgb_to_xyz(lrgb)
      mul_mat_vec(RGB_TO_XYZ, lrgb)
    end

    # Kubelka-Munk absorption/scattering parameter
    # Converts reflectance R to absorption/scattering coefficient KS
    def ks_from_reflectance(r)
      (1.0 - r)**2 / (2.0 * r)
    end

    # Inverse Kubelka-Munk function
    # Converts KS back to reflectance
    def reflectance_from_ks(ks)
      1.0 + ks - Math.sqrt(ks**2 + 2.0 * ks)
    end

    # Calculate luminance from XYZ (Y component)
    def luminance_from_xyz(xyz)
      [Float::EPSILON, xyz[1]].max
    end

    # Mix colors using Kubelka-Munk theory
    #
    # @param colors [Array<Hash>] Array of hashes with :color (Abachrome::Color) and :weight (Numeric)
    # @param tinting_strengths [Hash] Optional hash mapping colors to tinting strengths (default: 1.0)
    # @return [Abachrome::Color] The mixed color
    #
    # @example
    #   red = Abachrome.from_rgb(1, 0, 0)
    #   blue = Abachrome.from_rgb(0, 0, 1)
    #   mixed = Abachrome::Spectral.mix([{color: red, weight: 1}, {color: blue, weight: 1}])
    def mix(colors, tinting_strengths: {})
      # Convert colors to linear RGB and then to spectral reflectance
      spectral_data = colors.map do |data|
        color = data[:color]
        weight = data[:weight].to_f
        tinting_strength = tinting_strengths[color] || 1.0

        # Convert to linear RGB
        lrgb_color = color.to_color_space(:lrgb)
        lrgb = lrgb_color.coordinates.map(&:to_f)

        # Get spectral reflectance and KS values
        reflectance = lrgb_to_reflectance(lrgb)
        ks_values = reflectance.map { |r| ks_from_reflectance(r) }

        # Calculate XYZ for luminance
        xyz = reflectance_to_xyz(reflectance)
        luminance = luminance_from_xyz(xyz)

        # Calculate effective concentration
        # Note: weight is already normalized (sums to 1), so we don't square it
        # spectral.js squares 'factor' because it uses unnormalized values
        concentration = weight * tinting_strength**2 * luminance

        {
          ks_values: ks_values,
          concentration: concentration
        }
      end

      # Mix KS values using weighted average
      total_concentration = spectral_data.sum { |d| d[:concentration] }

      mixed_reflectance = Array.new(SIZE) do |i|
        ks_mix = spectral_data.sum { |d| d[:ks_values][i] * d[:concentration] }
        ks_mix /= total_concentration
        reflectance_from_ks(ks_mix)
      end

      # Convert back to RGB
      xyz = reflectance_to_xyz(mixed_reflectance)
      lrgb = xyz_to_lrgb(xyz)
      srgb = lrgb_to_srgb(lrgb)

      # Return as Color object
      Abachrome::Color.from_rgb(*srgb)
    end
  end
end
