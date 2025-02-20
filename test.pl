# Целочисленное значение
my $number = 42;
$number = 1e+18;  
$number = 8.41E-10;  
$number = 3.2e5; 
$number = 3.8;
$number = -0.005;
$number = 4.0;
$number = 5;
$number = -42;
$number = 1000000;

# Число с плавающей запятой
my $pi = 3.14159;
my $big_number = 1.23e5; # Экспоненциальная запись

# Строковое значение
my $text = "Hello, Perl!";

# Переменная без значения (undef)
my $undefined;
print "Undefined value: ", (defined $undefined ? "Yes" : "No");

# Объявление константы
use constant PI => 3.14159;
print PI; # Выведет 3.14159

# Объявление скалярной переменной
my $scalar = "Hello, Perl!";
print $scalar; # Выведет "Hello, Perl!"
our $global_var = "I'm global!";

# Объявление массива
my @array = (1, 2, 3, 4, 5);
print $array[0]; # Доступ к первому элементу (1)

# Объявление хэша
my %hash = (
    apple  => "red",
    banana => "yellow"
);
print $hash{"apple"}; # Выведет "red"

# Цикл for
for (my $i = 0; $i < 5; $i++) {
    print "$i ";
}

# Цикл foreach
my @numbers = (10, 20, 30);
foreach my $num (@numbers) {
    print "$num ";
}

# Цикл while
my $x = 0;
while ($x < 3) {
    print "$x ";
    $x++;
}

# Цикл until
my $y = 0;
until ($y >= 3) {
    print "$y ";
    $y++;
}
# Работа с массивом
my @colors = ("red", "green", "blue");
print $colors[1]; # Выведет "green"

# Работа с хэшем
my %capitals = (
    Russia => "Moscow",
    USA    => "Washington"
);
print $capitals{"Russia"}; # Выведет "Moscow"

# Использование ссылок
my $array_ref = [10, 20, 30];
print $array_ref->[1]; # Выведет 20

# Объявление функции
sub greet {
    my ($name) = @_;
    return "Hello, $name!";
}

# Вызов функции
print greet("Alice"); # Выведет "Hello, Alice!"

# Использование if-else
my $age = 20;
if ($age >= 18) {
    print "Adult";
} else {
    print "Minor";
}

# Использование unless
unless ($age < 18) {
    print "You are an adult";
}

# Использование given-when
use feature 'switch';
my $color = "red";
given ($color) {
    when ("red") { print "Stop!"; }
    when ("green") { print "Go!"; }
    default { print "Unknown color"; }
}
