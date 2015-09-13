class Pager
  def self.page(klass, page, count)
    klass.offset(count * page).limit(count)
  end

  def self.last(klass, count)
    klass.count / count
  end
end
