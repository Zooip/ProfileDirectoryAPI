class MasterData::PhoneNumber < MasterData::Base

   belongs_to :profile

   validates :number, numericality: { only_integer: true }
   validates :country_code, numericality: { only_integer: true }

  def format
    res={}
    res[:international]= "+#{country_code}#{number}"
    res[:readable_international]= "+#{country_code} #{number.to_s.scan(/.{1,3}/).join(" ")}"
    res[:readable_french]= ("0#{number}").scan(/.{1,2}/).join(".") if country_code == 33
    res
  end

  Phoner::Phone.default_country_code='33'
  def parse(raw)
    pn=Phoner::Phone.parse(raw)
    self.number="#{pn.area_code}#{pn.number}"
    self.country_code=pn.country_code
  end


end
