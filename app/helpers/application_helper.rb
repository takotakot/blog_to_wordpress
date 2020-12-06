module ApplicationHelper
  SLASH = '/'

  def normalize_uri(uri)
    # note: nfkc_normalize converts '･' to '・'
    # Addressable::URI.parse(uri).normalize.to_s
    result = uri.strip.split(SLASH, -1).map do |segment|
      ApplicationHelper.normalize_component(
        segment,
        Addressable::URI::CharacterClasses::PCHAR
      )
    end.join(SLASH)
  end

  def self.normalize_component(component, character_class=Addressable::URICharacterClasses::RESERVED + Addressable::URICharacterClasses::UNRESERVED, leave_encoded='')
    return nil if component.nil?

    begin
      component = component.to_str
    rescue NoMethodError, TypeError
      raise TypeError, "Can't convert #{component.class} into String."
    end if !component.is_a? String

    if ![String, Regexp].include?(character_class.class)
      raise TypeError,
        "Expected String or Regexp, got #{character_class.inspect}"
    end
    if character_class.kind_of?(String)
      leave_re = if leave_encoded.length > 0
        character_class = "#{character_class}%" unless character_class.include?('%')

        "|%(?!#{leave_encoded.chars.map do |char|
          seq = SEQUENCE_ENCODING_TABLE[char]
          [seq.upcase, seq.downcase]
        end.flatten.join('|')})"
      end

      character_class = /[^#{character_class}]#{leave_re}/
    end
    # We can't perform regexps on invalid UTF sequences, but
    # here we need to, so switch to ASCII.
    component = component.dup
    component.force_encoding(Encoding::ASCII_8BIT)
    # unencoded = self.unencode_component(component, String, leave_encoded)
    unencoded = self.unencode(component, String, leave_encoded)
    begin
      encoded = self.encode_component(
        # Addressable::IDNA.unicode_normalize_kc(unencoded),
        unencoded.unicode_normalize(:nfc),
        character_class,
        leave_encoded
      )
    rescue ArgumentError
      encoded = self.encode_component(unencoded)
    end
    encoded.force_encoding(Encoding::UTF_8)
    return encoded
  end

  def self.unencode(uri, return_type=String, leave_encoded='')
    return nil if uri.nil?

    begin
      uri = uri.to_str
    rescue NoMethodError, TypeError
      raise TypeError, "Can't convert #{uri.class} into String."
    end if !uri.is_a? String
    if ![String, ::Addressable::URI].include?(return_type)
      raise TypeError,
        "Expected Class (String or Addressable::URI), " +
        "got #{return_type.inspect}"
    end
    uri = uri.dup
    # Seriously, only use UTF-8. I'm really not kidding!
    uri.force_encoding("utf-8")
    leave_encoded = leave_encoded.dup.force_encoding("utf-8")
    result = uri.gsub(/%[0-9a-f]{2}/iu) do |sequence|
      c = sequence[1..3].to_i(16).chr
      c.force_encoding("utf-8")
      leave_encoded.include?(c) ? sequence : c
    end
    result.force_encoding("utf-8")
    if return_type == String
      return result
    elsif return_type == ::Addressable::URI
      return ::Addressable::URI.parse(result)
    end
  end

  ##
  # Tables used to optimize encoding operations in `self.encode_component`
  # and `self.normalize_component`
  SEQUENCE_ENCODING_TABLE = Hash.new do |hash, sequence|
    hash[sequence] = sequence.unpack("C*").map do |c|
      format("%02x", c)
    end.join
  end

  SEQUENCE_UPCASED_PERCENT_ENCODING_TABLE = Hash.new do |hash, sequence|
    hash[sequence] = sequence.unpack("C*").map do |c|
      format("%%%02X", c)
    end.join
  end

  def self.encode_component(component, character_class=
    CharacterClasses::RESERVED + CharacterClasses::UNRESERVED,
    upcase_encoded='')
    return nil if component.nil?

    begin
      if component.kind_of?(Symbol) ||
          component.kind_of?(Numeric) ||
          component.kind_of?(TrueClass) ||
          component.kind_of?(FalseClass)
        component = component.to_s
      else
        component = component.to_str
      end
    rescue TypeError, NoMethodError
      raise TypeError, "Can't convert #{component.class} into String."
    end if !component.is_a? String

    if ![String, Regexp].include?(character_class.class)
      raise TypeError,
        "Expected String or Regexp, got #{character_class.inspect}"
    end
    if character_class.kind_of?(String)
      character_class = /[^#{character_class}]/
    end
    # We can't perform regexps on invalid UTF sequences, but
    # here we need to, so switch to ASCII.
    component = component.dup
    component.force_encoding(Encoding::ASCII_8BIT)
    # Avoiding gsub! because there are edge cases with frozen strings
    component = component.gsub(character_class) do |sequence|
      SEQUENCE_UPCASED_PERCENT_ENCODING_TABLE[sequence]
    end
    if upcase_encoded.length > 0
      upcase_encoded_chars = upcase_encoded.chars.map do |char|
        SEQUENCE_ENCODING_TABLE[char]
      end
      component = component.gsub(/%(#{upcase_encoded_chars.join('|')})/,
                                &:upcase)
    end
    return component
  end
end
