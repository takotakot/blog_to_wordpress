def bulk_insert(classname, data)
  begin
    classname.upsert_all(data)
  rescue ArgumentError => exception
    data.each do |item|
      classname.find_or_create_by(item)
    end
  end
end
bulk_insert(Type, Type::HASH_DATA)
