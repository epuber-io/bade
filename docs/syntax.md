
# Syntax

## Already done

### Piped text `|`

Piped text is for adding simple text. Each following line indented greater than the pipe is copied.

	body
		p
			| This is text block.
				Text will be also in same text block.

Result will be:

	<body><p>This is text block.Text will be also in same text block.</p></body>


### Control code `-`

