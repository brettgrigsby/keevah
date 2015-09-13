class Pager

  def self.page(klass, page)
    klass.offset(24 * page).limit(24)
  end

end
