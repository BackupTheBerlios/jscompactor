# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 003.t'

#########################

# TODO: add test to catch out of order stuff (eg. bug # 5219)

use Test;

plan tests => 19;

use JavaScript::Squish;
ok(1); # If we made it this far, we're ok.

my $test_data = <<JAVASCRIPT;
/********************************
 * come copyright notice        *
 * laskfjslfjs ak fsakljfs kdf  *
 ********************************/

/* some single line comment */

    // another single comment

    var comment_in_string1 = "blah /* hehe */ //haha ";
    var comment_in_string2 = 'blah /* hehe */ //haha ';

    var test = "multi-line 
    text field";
    var test = "asfd asfd"; // comment 3

var x = "blah" + 'asdf' + tset + 'xx'+

'asdf';

    var foo = 'bar'; /* embeded comment */ var test = "xxx";
    var foo = 'bar';/*make sure this doesn't copy off surrounding chars*/var test = "xxx";

    var t = 'x';/*embeded multi line
    comment*/var asdf = 'qwer';

alert("this"+"is"+'some'+'more'+'text');

function blah (asdf) {
    while (x = el[ e++ ]) {
        y++;
    }
};
var x;   
// preceding line has ends in extra spaces up to
// here ^
var test_no_line_ending1 = "blah1"
var test_no_line_ending2 = "blah2"
if (x) { blah(); }
var x = "asdf";

// these should be treated as division
var x = 10 // see if this works
    / 2;
var x = 10 /* see if this works */ / 2;

// this should retain 4 spaces
var x = t.split(/    /);
// this should retain the newlines
var x = t.split(/ b l
 a h /);

JAVASCRIPT

my %t_out = (
    ### extract_strings_and_comments
    de_string   => qq|  _0_  

  _1_  

      _2_  

    var comment_in_string1 = "  0  ";
    var comment_in_string2 = '  1  ';

    var test = "  2  ";
    var test = "  3  ";   _3_  

var x = "  4  " + '  5  ' + tset + '  6  '+

'  7  ';

    var foo = '  8  ';   _4_   var test = "  9  ";
    var foo = '  10  ';  _5_  var test = "  11  ";

    var t = '  12  ';  _6_  var asdf = '  13  ';

alert("  14  "+"  15  "+'  16  '+'  17  '+'  18  ');

function blah (asdf) {
    while (x = el[ e++ ]) {
        y++;
    }
};
var x;   
  _7_  
  _8_  
var test_no_line_ending1 = "  19  "
var test_no_line_ending2 = "  20  "
if (x) { blah(); }
var x = "  21  ";

  _9_  
var x = 10   _10_  
    / 2;
var x = 10   _11_   / 2;

  _12_  
var x = t.split(/  22  /);
  _13_  
var x = t.split(/  23  /);
|,
    ### remove_comments1
    de_comment1 => qq|/********************************
 * come copyright notice        *
 * laskfjslfjs ak fsakljfs kdf  *
 ********************************/



    

    var comment_in_string1 = "  0  ";
    var comment_in_string2 = '  1  ';

    var test = "  2  ";
    var test = "  3  "; 

var x = "  4  " + '  5  ' + tset + '  6  '+

'  7  ';

    var foo = '  8  ';  var test = "  9  ";
    var foo = '  10  ';var test = "  11  ";

    var t = '  12  ';var asdf = '  13  ';

alert("  14  "+"  15  "+'  16  '+'  17  '+'  18  ');

function blah (asdf) {
    while (x = el[ e++ ]) {
        y++;
    }
};
var x;   


var test_no_line_ending1 = "  19  "
var test_no_line_ending2 = "  20  "
if (x) { blah(); }
var x = "  21  ";


var x = 10 
    / 2;
var x = 10  / 2;


var x = t.split(/  22  /);

var x = t.split(/  23  /);
|,
    ### remove_comments2
    de_comment2 => qq|



    

    var comment_in_string1 = "  0  ";
    var comment_in_string2 = '  1  ';

    var test = "  2  ";
    var test = "  3  "; 

var x = "  4  " + '  5  ' + tset + '  6  '+

'  7  ';

    var foo = '  8  ';  var test = "  9  ";
    var foo = '  10  ';var test = "  11  ";

    var t = '  12  ';var asdf = '  13  ';

alert("  14  "+"  15  "+'  16  '+'  17  '+'  18  ');

function blah (asdf) {
    while (x = el[ e++ ]) {
        y++;
    }
};
var x;   


var test_no_line_ending1 = "  19  "
var test_no_line_ending2 = "  20  "
if (x) { blah(); }
var x = "  21  ";


var x = 10 
    / 2;
var x = 10  / 2;


var x = t.split(/  22  /);

var x = t.split(/  23  /);
|,
    ### replace_white_space
    de_space    => qq|





var comment_in_string1 = "  0  ";
var comment_in_string2 = '  1  ';

var test = "  2  ";
var test = "  3  ";

var x = "  4  " + '  5  ' + tset + '  6  '+

'  7  ';

var foo = '  8  '; var test = "  9  ";
var foo = '  10  ';var test = "  11  ";

var t = '  12  ';var asdf = '  13  ';

alert("  14  "+"  15  "+'  16  '+'  17  '+'  18  ');

function blah (asdf) {
while (x = el[ e++ ]) {
y++;
}
};
var x;


var test_no_line_ending1 = "  19  "
var test_no_line_ending2 = "  20  "
if (x) { blah(); }
var x = "  21  ";


var x = 10
/ 2;
var x = 10 / 2;


var x = t.split(/  22  /);

var x = t.split(/  23  /);|,
    ### remove_blank_lines
    de_line => qq|var comment_in_string1 = "  0  ";
var comment_in_string2 = '  1  ';
var test = "  2  ";
var test = "  3  ";
var x = "  4  " + '  5  ' + tset + '  6  '+
'  7  ';
var foo = '  8  '; var test = "  9  ";
var foo = '  10  ';var test = "  11  ";
var t = '  12  ';var asdf = '  13  ';
alert("  14  "+"  15  "+'  16  '+'  17  '+'  18  ');
function blah (asdf) {
while (x = el[ e++ ]) {
y++;
}
};
var x;
var test_no_line_ending1 = "  19  "
var test_no_line_ending2 = "  20  "
if (x) { blah(); }
var x = "  21  ";
var x = 10
/ 2;
var x = 10 / 2;
var x = t.split(/  22  /);
var x = t.split(/  23  /);|,
    ### combine_concats
    de_concat   => qq|var comment_in_string1 = "  0  ";
var comment_in_string2 = '  1  ';
var test = "  2  ";
var test = "  3  ";
var x = "  4  " + '  5  ' + tset + '  6    7  ';
var foo = '  8  '; var test = "  9  ";
var foo = '  10  ';var test = "  11  ";
var t = '  12  ';var asdf = '  13  ';
alert("  14    15  "+'  16    17    18  ');
function blah (asdf) {
while (x = el[ e++ ]) {
y++;
}
};
var x;
var test_no_line_ending1 = "  19  "
var test_no_line_ending2 = "  20  "
if (x) { blah(); }
var x = "  21  ";
var x = 10
/ 2;
var x = 10 / 2;
var x = t.split(/  22  /);
var x = t.split(/  23  /);|,
    ### join_all
    joinall => qq|var comment_in_string1 = "  0  "; var comment_in_string2 = '  1  '; var test = "  2  "; var test = "  3  "; var x = "  4  " + '  5  ' + tset + '  6    7  '; var foo = '  8  '; var test = "  9  "; var foo = '  10  ';var test = "  11  "; var t = '  12  ';var asdf = '  13  '; alert("  14    15  "+'  16    17    18  '); function blah (asdf) { while (x = el[ e++ ]) { y++; } }; var x; var test_no_line_ending1 = "  19  "\nvar test_no_line_ending2 = "  20  "\nif (x) { blah(); }\nvar x = "  21  "; var x = 10 / 2; var x = 10 / 2; var x = t.split(/  22  /); var x = t.split(/  23  /);|,
    ### replace_extra_whitespace
    de_space2   => qq|var comment_in_string1="  0  ";var comment_in_string2='  1  ';var test="  2  ";var test="  3  ";var x="  4  "+'  5  '+tset+'  6    7  ';var foo='  8  ';var test="  9  ";var foo='  10  ';var test="  11  ";var t='  12  ';var asdf='  13  ';alert("  14    15  "+'  16    17    18  ');function blah(asdf){while(x=el[e++]){y++;}};var x;var test_no_line_ending1="  19  "\nvar test_no_line_ending2="  20  "\nif(x){blah();}var x="  21  ";var x=10/2;var x=10/2;var x=t.split(/  22  /);var x=t.split(/  23  /);|,
    ### restore_literal_strings
    re_string   => qq|var comment_in_string1="blah /* hehe */ //haha ";var comment_in_string2='blah /* hehe */ //haha ';var test="multi-line 
    text field";var test="asfd asfd";var x="blah"+'asdf'+tset+'xxasdf';var foo='bar';var test="xxx";var foo='bar';var test="xxx";var t='x';var asdf='qwer';alert("thisis"+'somemoretext');function blah(asdf){while(x=el[e++]){y++;}};var x;var test_no_line_ending1="blah1"\nvar test_no_line_ending2="blah2"\nif(x){blah();}var x="asdf";var x=10/2;var x=10/2;var x=t.split(/    /);var x=t.split(/ b l
 a h /);|,
    ### replace_final_eol
    re_eol  => qq|var comment_in_string1="blah /* hehe */ //haha ";var comment_in_string2='blah /* hehe */ //haha ';var test="multi-line 
    text field";var test="asfd asfd";var x="blah"+'asdf'+tset+'xxasdf';var foo='bar';var test="xxx";var foo='bar';var test="xxx";var t='x';var asdf='qwer';alert("thisis"+'somemoretext');function blah(asdf){while(x=el[e++]){y++;}};var x;var test_no_line_ending1="blah1"\nvar test_no_line_ending2="blah2"\nif(x){blah();}var x="asdf";var x=10/2;var x=10/2;var x=t.split(/    /);var x=t.split(/ b l
 a h /);
|,
    );


my $djc = JavaScript::Squish->new();
ok( defined $djc, 1, 'new() did not return anything' );
ok( $djc->isa('JavaScript::Squish') );

$djc->data($test_data);
my $t = $djc->data();
ok( $t, $test_data, "set data to be processed" );

my $eol = $djc->determine_line_ending();
ok( $eol, "\n", "figured out EOL character" );
$eol = $djc->eol_char();
ok( $eol, "\n", "fetching EOL character" );
$eol = $djc->eol_char("xxx");
ok( $eol, "xxx", "setting EOL character" );
$eol = $djc->eol_char("\n");
ok( $eol, "\n", "re-setting EOL character" );

$t = $djc->data();
ok( $t, $test_data, "test data has not changed" );

$djc->extract_strings_and_comments();
$t = $djc->data();
ok( $t, $t_out{de_string}, "extract_strings_and_comments" );

$djc->remove_comments(exceptions => qr/copyright/i);
$t = $djc->data();
ok( $t, $t_out{de_comment1}, "remove_comments1" );

$djc->remove_comments();
$t = $djc->data();
ok( $t, $t_out{de_comment2}, "remove_comments2" );

$djc->replace_white_space();
$t = $djc->data();
ok( $t, $t_out{de_space}, "replace_white_space" );

$djc->remove_blank_lines();
$t = $djc->data();
ok( $t, $t_out{de_line}, "remove_blank_lines" );

$djc->combine_concats();
$t = $djc->data();
ok( $t, $t_out{de_concat}, "combine_concats" );

$djc->join_all();
$t = $djc->data();
ok( $t, $t_out{joinall}, "join_all" );

$djc->replace_extra_whitespace();
$t = $djc->data();
ok( $t, $t_out{de_space2}, "replace_extra_whitespace" );

$djc->restore_literal_strings();
$t = $djc->data();
ok( $t, $t_out{re_string}, "restore_literal_strings" );

$djc->replace_final_eol();
$t = $djc->data();
ok( $t, $t_out{re_eol}, "replace_final_eol" );



