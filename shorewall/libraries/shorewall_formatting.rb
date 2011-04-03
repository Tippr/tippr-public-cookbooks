def shorewall_format_file(column_defs, data)
  retval = ''
  data.each { |element|
    retval << "\n"
    if element[:description] then
      retval << "# "
      retval << element[:description]
      retval << "\n"
    end
    pos = 0
    column_defs.each { |key, width|
      pos += width
      value = element.fetch(key, '-').to_s
      retval << (('%%-%ds' % width) % value)
      if width != 0 and value.length >= width then
        retval << (" \\\n" + (' ' * pos))
      end
    }
    retval << "\n"
  }
  return retval
end

# vim: ai et sts=2 sw=2 ts=2
