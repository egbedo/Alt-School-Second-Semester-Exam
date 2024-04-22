#update packages
sudo apt update -y
#install apache2, mysql-server, php, libapache2-mod-php, php-mysql, git
sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql git
#add php repository
echo | sudo add-apt-repository -y ppa:ondrej/php
#update again
sudo apt update -y
#install php8.3, php8.3-curl,
sudo apt install -y php libapache2-mod-php php-mysql php8.3 php8.3-curl php8.3-dom php8.3-xml php8.3-mysql php8.3-sqlite3 zip unzip -y
#remove php7.4
sudo apt-get purge -y php7.4 php7.4-common -y
#update again
sudo apt update -y
#run a rewrite module
sudo a2enmod rewrite
#activate php8.3
sudo a2enmod php8.3
#restart apache2
sudo systemctl restart apache2
# Define MySQL password
MYSQL_PWD="mrdaniel123"

# Define new database parameters
username="daniellaravel"
password="mrdaniel123"
database="danieldatabase"

# Execute SQL commands
mysql -u root -p$MYSQL_PWD <<MYSQL_SCRIPT
CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';
CREATE DATABASE $database;
GRANT ALL ON $database.* TO '$username'@'localhost';
FLUSH PRIVILEGES;
SHOW DATABASES;
MYSQL_SCRIPT
echo "Database has been created successfully!"

# change ownership
sudo chown vagrant:vagrant /etc/apache2/sites-available/laravel.conf
#navigate to root directory
cd /usr/bin
#install composer
echo | curl -sS https://getcomposer.org/installer | sudo php
#rename composer.phar to composer
sudo mv composer.phar /usr/local/bin/composer
#navigate to laravel directory
cd /var/www/laravel
#change ownership to vagrant
sudo chown -R vagrant:vagrant /var/www/laravel
#run as vagrant user
sudo -u vagrant touch database/database.sqlite
#run as vagrant user
sudo -u vagrant composer install --optimize-autoloader --no-dev --no-interaction
#update composer
sudo -u vagrant composer update
#copy .env.example to .env
sudo -u vagrant cp .env.example .env
#edit .env file
# Define new database parameters
db_name="danieldatabase"
db_user="daniellaravel"
db_pass="mrdaniel123"
db_host="localhost"
db_port="3306"

# Define the configuration
document_root="/var/www/laravel/public"
server_name="laravel.local"
server_alias="www.laravel.local"

# Navigate to laravel directory
cd /var/www/laravel

# Change ownership to vagrant
sudo chown -R vagrant:vagrant /var/www/laravel

# Run composer update as vagrant user
sudo -u vagrant composer update --no-interaction

# Copy .env.example to .env
sudo -u vagrant cp .env.example .env

# Edit .env file
sudo -u vagrant sed -i "s/DB_DATABASE=.*/DB_DATABASE=$db_name/" .env
sudo -u vagrant sed -i "s/DB_USERNAME=.*/DB_USERNAME=$db_user/" .env
sudo -u vagrant sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$db_pass/" .env
sudo -u vagrant sed -i "s/DB_HOST=.*/DB_HOST=$db_host/" .env
sudo -u vagrant sed -i "s/DB_PORT=.*/DB_PORT=$db_port/" .env

echo ".env file has been updated successfully!"

# Generate key
sudo -u vagrant php artisan key:generate --no-interaction

# Run migration
sudo -u vagrant php artisan migrate --force

# Change ownership to www-data for Apache
sudo chown -R www-data:www-data /var/www/laravel
sudo chmod -R 755 /var/www/laravel
sudo chown -R www-data:www-data /var/www/laravel/bootstrap/cache
sudo chown -R www-data:www-data /var/www/laravel/storage

# Configure apache
cd /etc/apache2/sites-available

# Copy default file to laravel.conf
sudo cp 000-default.conf laravel.conf

# Edit laravel.conf
sudo sed -i "s|DocumentRoot /var/www/html|DocumentRoot $document_root|" laravel.conf
sudo sed -i "/DocumentRoot $document_root/a\ \n\tServerName $server_name\n\tServerAlias $server_alias" laravel.conf

# Enable site and reload Apache
sudo a2ensite laravel.conf
sudo systemctl reload apache2