#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Path qw/rmtree/;
use Data::Dumper;sub d{ warn Dumper @_ };

my $help;
GetOptions ("help" => \$help);
usage() if $help;

my $command_exist = `type markdown`;
die '$ markdown: not found' unless $command_exist;

my $input_dir = shift || usage();
my $output_dir = $input_dir . "_html";

my @markdowns = ();
opendir(INPUTDIR, $input_dir) or die($!);
for (readdir(INPUTDIR)){
    next unless $_ =~ ".md\E";
    push(@markdowns, $_);
}
closedir(INPUTDIR);

rmtree $output_dir if -d $output_dir;
mkdir $output_dir;

for (@markdowns) {
    my $input_markdown = "$input_dir/$_";
    my $output_file = "$output_dir/$_.html";
    next unless -e $input_markdown;
    my $body = `markdown $input_markdown`;
    my $contents = html_wrapper($body, \@markdowns);
    $contents =~ s/<code>/<pre><code>/gi;
    $contents =~ s|</code>|</code></pre>|gi;
    open OUT, "> $output_file";
    print OUT $contents;
    close OUT;
    print "generate $output_file\n";
}
print "done.\n";


sub html_wrapper {
    my ($body, $contents) = @_;

    my $content_list = join('', map {
        sprintf "<li><a href=\"%s\">%s</a></li>", $_ . ".html", $_
    } @$contents);
    my $header = sprintf "
<html>
  <head>
    <title>Slick Documentation in Japanese</title>
    <meta charset=\"UTF-8\">
    <link rel=\"stylesheet\" href=\"http://yui.yahooapis.com/pure/0.3.0/pure-min.css\">
    <style>
        li {
          margin: 20px 0;
        }
        pre {
          background-color: #f8f8f8;
          border: 1px solid #ddd;
          padding: 6px 10px;
          border-radius: 3px;
        }
    </style>
  </head>
  <body>
    <div class=\"pure-g\" style=\"width:80%%; margin: auto\">
      <div class=\"pure-u-1-4\">
        <div style=\"position: fixed; margin: 100px 0\">
          <a>Table of Contents</a>
          <ul>%s</ul>
        </div>
      </div>
      <div class=\"pure-u-3-4\">
        <div style=\"padding: 20px\">", $content_list;
    my $footer = "</div></div></div></body></html>";

    return $header . $body . $footer;
}

sub usage {
    my $usage = <<'...';
USAGE
  ./markdown2html.pl input-dir
  e.g:
    ./markdown2html.pl v1.0
    ./markdown2html.pl v2.0
  dependency:
    markdown
...
    die $usage;
}
__END__
