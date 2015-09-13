class Pager
  def self.page(klass, page, count)
    klass.offset(count.to_i * page).limit(count)
  end

  def self.last(klass, count)
    total = klass.count
    last_page = total / count.to_i
    total % count.to_i != 0 ? last_page : last_page - 1
  end
end
