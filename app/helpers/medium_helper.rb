module MediumHelper
  def self.title(medium)
    medium.title
  end

  def self.alt_text(medium)
    medium.alt
  end

  def self.date(medium)
    medium.oldest_date
  end
end
