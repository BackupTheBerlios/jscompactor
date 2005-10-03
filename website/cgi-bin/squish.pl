#!/usr/bin/perl

# NOTE: This script is royal crap. It's just here for an example.
#       I wouldn't recommend borrowing anything from it, and hope
#       you don't judge my work from this :-)

use strict;
use CGI qw(:standard);
use lib qw(/home/users/unrtst/lib/JavaScript-Squish/lib);
use JavaScript::Squish;

&main;

sub main
{
    my $self = __PACKAGE__->new();
    $self->init();

    $self->print_top();

    $Q::style ||= 'basic';

    if ($Q::style eq 'basic')
    {
        $self->print_basic();

    } elsif ($Q::style eq 'advanced') {
        $self->print_advanced();

    } else {
        print "<CENTER><H1>INVALID OPTIONS PASSED IN</H1></CENTER>\n";
    }

    $self->print_bottom();
}

sub print_basic
{
    my $self = shift;

    my $results = "";
    if ($Q::data) {
        $results = $self->process_basic();
    }

    my $exceptions = $Q::data ? $Q::exceptions : 'copyright';
    my $case_insensitive = ($Q::data && $Q::case_insensitive) ? 'checked' :
                           ($Q::data)                         ? ''        :
                                                                'checked' ;
    my $escaped_exceptions = $self->cgi->escapeHTML($exceptions);
    my $escaped_data = $self->cgi->escapeHTML($Q::data);
    my $escaped_results = $self->cgi->escapeHTML($results);
    print <<HTML;
<FORM METHOD=post>
<INPUT TYPE=hidden NAME=style VALUE="basic">
If filled in, any comments matching the supplied text will NOT be removed from your code.<BR>
Comments Exception: <INPUT TYPE=text name="exceptions" VALUE="$escaped_exceptions"> Ignore Case : <INPUT TYPE=checkbox name=case_insensitive value=1 $case_insensitive><BR>

<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" BGCOLOR="#000000"><TR><TD>
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 BGCOLOR="#DEDEEE">
<TR><TD>Input</TD></TR>
<TR><TD><TEXTAREA NAME="data" ROWS=10 COLS=80 WRAP=OFF>$escaped_data</TEXTAREA></TD></TR>
</TABLE>
</TD></TR></TABLE>

<INPUT TYPE=reset VALUE="Clear"><INPUT TYPE=SUBMIT VALUE=Squish><BR>

<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" BGCOLOR="#000000"><TR><TD>
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 BGCOLOR="#DEDEEE">
<TR><TD>Output</TD></TR>
<TR><TD><TEXTAREA NAME="results" ROWS=10 COLS=80 WRAP=OFF>$escaped_results</TEXTAREA></TD></TR>
</TABLE>
</TD></TR></TABLE>

</FORM>
HTML
}

sub process_basic
{
    my $self = shift;

    my %opts;
    $Q::exceptions =~ s/^\s+//;
    $Q::exceptions =~ s/\s+$//;
    if ($Q::exceptions)
    {
        my $quoted = "\Q$Q::exceptions\E";
        my $opt = $Q::case_insensitive ? 'i' : '';
        $opts{remove_comments_exceptions} = eval ( "qr/$quoted/$opt" );
    }

    my $compacted = JavaScript::Squish->squish( $Q::data, %opts )
        or die $JavaScript::Squish::err_msg;

    return $compacted;
}

sub print_advanced
{
    my $self = shift;

    my $other_opts = [
        { method => 'remove_comments',          name => 'Remove Comments' },
        { method => 'replace_white_space',      name => 'Squish Consecutive Whitespace' },
        { method => 'remove_blank_lines',       name => 'Remove Blank Lines' },
        { method => 'combine_concats',          name => 'Combine literal string concatenations' },
        { method => 'join_all',                 name => 'Put All on One Line' },
        { method => 'replace_extra_whitespace', name => 'Replace unneccessary Whitespace' },
        { method => 'replace_final_eol',        name => 'Replace Final EOL' },
        ];

    my $results = "";
    if ($Q::data) {
        $results = $self->process_advanced($other_opts);
    }

    my $number_of_exceptions = 5; # how many we'll generate
    my @exceptions = @Q::exceptions;
    my @excep_case = @Q::case_insensitive;
    if (! $Q::data)
    {
        $exceptions[0] = 'copyright';
        $excep_case[0] = '1';
    }
    for (my $i=0; $i<$number_of_exceptions; $i++)
    {
        $exceptions[$i] = $self->cgi->escapeHTML($exceptions[$i]);
        $excep_case[$i] = $excep_case[$i] ? 'checked' : '';
    }

    my $escaped_data = $self->cgi->escapeHTML($Q::data);
    my $escaped_results = $self->cgi->escapeHTML($results);
    print <<HTML;
<FORM METHOD=post>
<INPUT TYPE=hidden NAME=style VALUE="advanced">
<TABLE BORDER=1 WIDTH=100% CELLPADDING=0 CELLSPACING=0>
<TR>
    <TD>If filled in, any comments matching the supplied text will NOT be removed from your code.<BR>
HTML
    for (my $i=0; $i<$number_of_exceptions; $i++)
    {
        print <<HTML;
    Comments Exception: <INPUT TYPE=text name="exceptions" VALUE="$exceptions[$i]"> Ignore Case : <INPUT TYPE=checkbox name=case_insensitive value=1 $excep_case[$i]><BR>
HTML
    }
    print "</TD></TR>\n";

    foreach my $opt (@{$other_opts})
    {
        my $checked = $self->cgi->param($$opt{method}) ? 'checked' : '';
        print <<OPTION;
<TR><TD><INPUT TYPE=checkbox name="$$opt{method}" value=1 $checked> $$opt{name}</TD></TR>
OPTION
    }

    print <<HTML;

</TABLE>

<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" BGCOLOR="#000000"><TR><TD>
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 BGCOLOR="#DEDEEE">
<TR><TD>Input</TD></TR>
<TR><TD><TEXTAREA NAME="data" ROWS=10 COLS=80 WRAP=OFF>$escaped_data</TEXTAREA></TD></TR>
</TABLE>
</TD></TR></TABLE>

<INPUT TYPE=reset VALUE="Clear"><INPUT TYPE=SUBMIT VALUE=Squish><BR>

<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" BGCOLOR="#000000"><TR><TD>
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 BGCOLOR="#DEDEEE">
<TR><TD>Output</TD></TR>
<TR><TD><TEXTAREA NAME="results" ROWS=10 COLS=80 WRAP=OFF>$escaped_results</TEXTAREA></TD></TR>
</TABLE>
</TD></TR></TABLE>

</FORM>
HTML
}

sub process_advanced
{
    my $self = shift;
    my $other_opts = shift;

    my $js = JavaScript::Squish->new();
    $js->data($Q::data);
    $js->determine_line_ending();

    my @remove_comment_exceptions;
    my @exceptions = @Q::exceptions;
    my @excep_case = @Q::case_insensitive;
    for (my $i=0; $i<@exceptions; $i++)
    {
        $exceptions[$i] =~ s/^\s+//;
        $exceptions[$i] =~ s/\s+$//;
        if ($exceptions[$i])
        {
            my $quoted = "\Q$exceptions[$i]\E";
            my $opt = $excep_case[$i] ? 'i' : '';
            my $regexp = eval ( "qr/$quoted/$opt" );
            push(@remove_comment_exceptions, $regexp);
        }
    }

    foreach my $opt (@{$other_opts})
    {
        next unless $self->cgi->param($$opt{method});

        if ($$opt{method} eq 'remove_comments') {
            $js->remove_comments(exceptions => \@remove_comment_exceptions);
        } elsif ($$opt{method} eq 'replace_white_space') {
            $js->replace_white_space();
        } elsif ($$opt{method} eq 'remove_blank_lines') {
            $js->remove_blank_lines();
        } elsif ($$opt{method} eq 'combine_concats') {
            $js->combine_concats();
        } elsif ($$opt{method} eq 'join_all') {
            $js->join_all();
        } elsif ($$opt{method} eq 'replace_extra_whitespace') {
            $js->replace_extra_whitespace();
        } elsif ($$opt{method} eq 'replace_final_eol') {
            $js->replace_final_eol();
        } else {
            die "INVALID OPTION PASSED IN [$$opt{method}]\n";
        }
    }

    return $js->data;
}

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my %opts = @_;

    my $self = { };

    bless $self, $class;

    return $self;
}

sub init
{
    my $self = shift;
    $self->cgi( new CGI );
    $self->cgi->import_names('Q'); # pull all cgi vars into 'Q' namespace
}

sub cgi
{
    my $self = shift;
    if ($_[0]) {
        $self->{_cgi} = $_[0];
    } else {
        return $self->{_cgi};
    }
}

sub print_top
{
    my $self = shift;
    print header;
    print <<HTML;
<HTML>
<HEAD>
    <TITLE>JavaScript::Squish - Compact JavaScript code to minimal length</TITLE>
</HEAD>

<BODY BGCOLOR="#FFFFFF">

<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="100%" BGCOLOR="#000000"><TR><TD>
<TABLE BORDER="0" WIDTH="100%" BGCOLOR="#FFFFFF">
<TR>
<TD ALIGN="left"><H1><A HREF="/"><FONT COLOR="#000000">JavaScript::Squish</FONT></A></H1></TD>
<TD ALIGN="right"><A href="http://developer.berlios.de" title="BerliOS Developer"> <img src="http://developer.berlios.de/bslogo.php?group_id=4847" width="124px" height="32px" border="0" alt="BerliOS Developer Logo"></A></TD>
</TR>

</TABLE>
<TABLE BORDER="0" WIDTH="100%" BGCOLOR="#DEDEEE">
<TR>
    <TH><A HREF="https://developer.berlios.de/projects/jscompactor/">Project Page</A></TH>
    <TH><A HREF="http://search.cpan.org/dist/JavaScript-Squish/">CPAN listing</A></TH>
    <TH><A HREF="http://search.cpan.org/dist/JavaScript-Squish/lib/JavaScript/Squish.pm">Documentation</A></TH>
</TR>
<TR>
    <TH><A HREF="/cgi-bin/squish.pl?style=basic">Demo (basic)</A></TH>
    <TH><A HREF="/cgi-bin/squish.pl?style=advanced">Demo (advanced)</A></TH>
    <TH><A HREF="https://developer.berlios.de/project/showfiles.php?group_id=4846">Download</A></TH>
</TR>
</TABLE>

</TD></TR></TABLE>

HTML

}

sub print_bottom
{
    my $self = shift;
    print "</BODY></HTML>\n";
}
