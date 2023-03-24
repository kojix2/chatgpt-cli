struct Lexbor::Node
  def displayble?
    visible? && !object? && !is_tag_noindex?
  end
end

def words(parser)
  parser
    .nodes(:_text)                         # iterate through all TEXT nodes
    .select(&.parents.all?(&.displayble?)) # select only which parents are visible good tag
    .map(&.tag_text)                       # mapping node text
    .reject(&.blank?)                      # reject blanked texts
    .map(&.strip.gsub(/\s{2,}/, " "))      # remove extra spaces
end