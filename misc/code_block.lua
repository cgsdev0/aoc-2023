function CodeBlock(el)
    -- Wrap the content of the code block in triple backticks
    return pandoc.RawBlock('markdown', '```\n' .. el.text .. '\n```')
end
