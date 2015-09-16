class Pager
  def self.page(klass, page, count)
    klass.offset(count.to_i * page).limit(count)
  end

  def self.last(klass, count)
    if klass.class == Class
      total = klass.count
    else
      total = klass.size
    end
    last_page = total / count.to_i
    total % count.to_i != 0 ? last_page : last_page - 1
  end

  def self.range(current_page, total)
    lower_limit = current_page - 5
    upper_limit = current_page + 5
    lower_limit = 1 if lower_limit < 1
    upper_limit = total if upper_limit > total
    (lower_limit..upper_limit)
  end
end
