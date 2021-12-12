module ApplicationHelper
  def flash_class(key)
    if key == "notice"
      return "alert-primary"
    elsif key == "alert"
      return "alert-warning"
    end

    "alert-#{key}"
  end
end
