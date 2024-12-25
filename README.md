# Dzhaga_DB_project

Вам для улыбки:

![Jokes Card](https://readme-jokes.vercel.app/api)

А теперь к серьезному: 

# Инструкция по выполнению
1. Установите Docker Desktop и DBeaver Community
2. Запустите PostgreSQL через Docker Compose по иснтрукции со следующей ссылки (container_name заменить на sql_wednesday):
[запуск PostgreSQL через Docker Compose](https://habr.com/ru/articles/823816/)
4. Проверьте в Docker Desktop, что контейнер запущен
![image](https://github.com/user-attachments/assets/38e23fde-e710-437b-8910-e157f34093f1)
5. Зайдите в DBeaver Community и нажмите Ctrl + Shift + N. Далее заполните подключение, как на изображении ниже
![image](https://github.com/user-attachments/assets/4305c3f7-793c-4d80-9788-e9dbbef6efd5)
6. С помощью скриптов из папки "Cкрипты создания таблиц источников" - создать пустые таблицы источников в PostgreSQL
7. С помощью DBeaver импортировать данные из csv файлов в папке "Данные для источников" в пустые таблицы, созданные на предыдущем шаге. Нажмите правой кнопкой на таблицу схемы и выберите импорт данных, как показано на изображении ниже
![image](https://github.com/user-attachments/assets/b8daef55-9f49-4d69-a25f-86a7ba9167cd)
8. Нажмите Ctrl + ]. У вас откроется окно для нового sql скрипта. Запустите скрипты по созданию схемы DWH и витрины и в ней таблиц, которые располагаются в папке "Скрипты по созданию таблиц DWH и витрины"
9. Запустите скрипт push_cus_cra_pro.sql для заполнения таблиц таблиц измерений (Dimension) DWH (кроме f_orders).
10. Запустите скрипт push_orders.sql для заполнения таблицы измерений для заказов f_orders.
11. Запустите скрипт push_datamart.sql для заполнения аналитического хранилища данных (витрины) и файла отчетности
12. Тестируйте

Приятного принятия зачета!
