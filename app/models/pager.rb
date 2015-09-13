class Pager
  def self.page(klass, page, count)
    klass.offset(count.to_i * page).limit(count)
  end

  def self.last(klass, count)
    klass.count / count.to_i
  end
end
