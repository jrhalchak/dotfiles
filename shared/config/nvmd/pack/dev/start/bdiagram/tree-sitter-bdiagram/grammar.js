module.exports = grammar({
  name: 'bdiagram',

  rules: {
    source_file: $ => repeat($._block),

    _block: $ => choice(
      $.bdiagram_block,
      $.other
    ),

    bdiagram_block: $ => seq(
      '@bdiagram',
      '\n',
      repeat1($.diagram_line),
      '@end'
    ),

    diagram_line: $ => seq(
      optional($.diagram_indent),
      repeat1($.diagram_char),
      '\n'
    ),

    diagram_indent: $ => /[ ]+/,

    diagram_char: $ => token(choice(
      '+', '-', '=', '_', '~', '|', ':', ';', '!', // box drawing
      '>', '<', '^', 'v',                          // arrows
      'w', 'm',                                    // wavy
      ' ',                                         // space
      /[A-Za-z0-9]/,                               // text/labels
      '[', ']', '{', '}', '(', ')', '.', ',', '\'', '"', '/', '\\', '?', '@', '#', '$', '%', '&', '*', '`', '~'
    )),

    other: $ => /[^\n]+/
  }
});
