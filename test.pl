# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..16\n"; }
END {print "not ok 1\n" unless $loaded;}
use Text::Macros;
$loaded = 1;
report(1);

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

sub report {
	$TEST_NUM++;
	print ( $_[0] ? "ok $TEST_NUM\n" : "not ok $TEST_NUM\n" );
}

%macval = (
  alpha => 'foo',
  gamma => 'bar',
);

$D0 = bless {}, 'D0';
$D1 = bless {}, 'D1';

$A0 = new Text::Macros qw( {{ }} );   report( defined $A0 );
$A1 = new Text::Macros qw( {{ }} 1 ); report( defined $A1 );
$B0 = new Text::Macros "\Q[[", "\Q]]";    report( defined $B0 );
$B1 = new Text::Macros "\Q[[", "\Q]]", 1; report( defined $B1 );

test0( $A0, $D0, 'A{{alpha}}B' => "A$macval{'alpha'}B" );

test0( $A0, $D0, 'A {{alpha}} B' => "A $macval{'alpha'} B" );
test0( $A0, $D0, 'A {{ alpha }} B' => "A $macval{'alpha'} B" );
test0( $A0, $D0, 'A {{alpha}} B {{gamma}} C' => "A $macval{'alpha'} B $macval{'gamma'} C" );

test0( $B0, $D0, 'A[[alpha]]B' => "A$macval{'alpha'}B" );

test0( $A1, $D0, 'A{{alpha}}B' => "A$macval{'alpha'}B" );
test0( $B1, $D0, 'A[[alpha]]B' => "A$macval{'alpha'}B" );

test0( $A1, $D1, 'A{{alpha}}B' => "A$macval{'alpha'}B" );
test0( $B1, $D1, 'A[[alpha]]B' => "A$macval{'alpha'}B" );

test1( $A0, $D1, 'A{{alpha}}B' => "A$macval{'alpha'}B" );
test1( $B0, $D1, 'A[[alpha]]B' => "A$macval{'alpha'}B" );

###################################################################


sub test0 {
  my( $macros, $data_obj, $template, $expected_result ) = @_;
  my $result = $macros->expand_macros( $data_obj, $template );

  report($result eq $expected_result);

  $result ne $expected_result  and
  $ENV{TEST_VERBOSE} and
    print STDERR "'$result' ne '$expected_result'\n";
}

sub test1 {
  my( $macros, $data_obj, $template, $expected_result ) = @_;
  my $result;
  eval {
    $result = $macros->expand_macros( $data_obj, $template );
  };

  report( defined($@) and ( $@ =~ /Can't/ ) );

  $ENV{TEST_VERBOSE} and
    print STDERR "$@\n";
}

sub D0::alpha { $macval{'alpha'} }
sub D0::gamma { $macval{'gamma'} }

sub D1::AUTOLOAD {
  my $self = shift;
  my $name = $D1::AUTOLOAD;
  $name =~ s/.*:://;
  $macval{$name}
}

