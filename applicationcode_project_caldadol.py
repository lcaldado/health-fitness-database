import pymysql

#Function to create an account 
def create_account(connection): 
    successful_creation=False
    cursor1=connection.cursor()
    while not successful_creation:
        try:
            mail= input('Introduce mail: ')
            while mail==None:
                mail= input('Introduce valid mail: ')
            first_name=input('Introduce first_name : ')
            last_name=input('Introduce last_name : ')
            age=input('Introduce age: ')
            gender=input('Introduce gender: ')
            height=input('Introduce height: ')
            weight=input('Introduce weight: ')
            cursor1.callproc('create_user', args=[mail,first_name,last_name,age,gender,height,weight])
            connection.commit()
            cursor1.close()
            successful_creation=True
        except pymysql.MySQLError as error:
            print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
            print("Please try again.")
    #Now we find the user_id created 
    sql_statement='SELECT user_id FROM user ORDER BY user_id DESC LIMIT 1'
    cursor2=connection.cursor()
    cursor2.execute(sql_statement)
    user_id=cursor2.fetchone()
    cursor2.close()
    return user_id

#Function to add a new goal
def add_new_goal(connection,user_id):
    successful_operation=False
    cursor1=connection.cursor()
    while not successful_operation:
        try:
            type=input('Introduce type of goal : ')
            target_value=input('Introduce target value: ')
            start_date=input('Introduce start date : ')
            target_date=input('Introduce target date: ')
            status=input('Introduce status of goal (in progress / finished / not started) : ')
            cursor1.callproc('add_goal', args=[user_id,type,target_value,start_date,target_date,status])
            connection.commit()
            cursor1.close()
            successful_operation=True
        except pymysql.MySQLError as error:
            print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
            print("Please try again.")  
    print('Goal added successfully!')

#Function to track health test
def track_health_test(connection,user_id):
    successful_operation=False
    cursor1=connection.cursor()
    while not successful_operation:
        try:
            body_fat=input('Introduce body fat % : ')
            heart_rate=input('Introduce heart rate: ')
            blood_pressure=input('Introduce blood pressure: ')
            date=input('Introduce date: ')
            cursor1.callproc('track_health_test', args=[user_id,body_fat,heart_rate,blood_pressure,date])
            connection.commit()
            cursor1.close()
            successful_operation=True
        except pymysql.MySQLError as error:
            print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
            print("Please try again.")
    print('Health test added successfully!')

#Function to track a meal
def track_meal(connection,user_id): 
    successful_operation=False
    cursor1=connection.cursor()
    while not successful_operation:
        try:
            goal_id=input('Introduce goal id that it is related to this meal: ')
            meal_date=input('Introduce date : ')
            type=input('Introduce type of meal: ')
            calories=input('Introduce number of calories: ')
            protein=input('Introduce grams of protein: ')
            carbs=input('Introduce grams of carbs: ')
            fat=input('Introduce grams of fat: ')
            cursor1.callproc('track_meal', args=[goal_id,user_id,meal_date,type,calories,protein,carbs,fat])
            connection.commit()
            cursor1.close()
            successful_operation=True
        except pymysql.MySQLError as error:
            print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
            print("Please try again.")
    print('Meal added succesfully!')

#Function to add exercise to a workout
def add_exercise_to_workout(connection,workout_id):
    print('1. Add exercise already created')
    print('2. Add new exercise')
    choice=input('Choose an option (1 or 2) : ')
    if choice=='1':
        while True: 
            cursor1=connection.cursor()
            sql_stam="select * from exercise"
            cursor1.execute(sql_stam)
            possible_exercises=cursor1.fetchall()
            possible_exercise_names=[ex['exercise_name'] for ex in possible_exercises]
            print('List of exercise names : ')
            for ex in possible_exercise_names:
                print(ex)
            cursor1.close()
            exercise_name=input('Enter exercise name that you want to add to workout: ')
            if exercise_name in possible_exercise_names:
                break
            else:
                print('exercise name not valid')
        successful_operation=False
        cursor2=connection.cursor()
        while not successful_operation:
            try:
                cursor2.callproc('new_exercise_in_workout', args=[exercise_name,workout_id])
                connection.commit()
                cursor2.close()
                successful_operation=True
            except pymysql.MySQLError as error:
                print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
                print("Please try again.")
        print('Exercise added to workout!')
    elif choice=='2':
        successful_operation=False
        cursor3=connection.cursor()
        while not successful_operation:
            try:
                exercise_name=input('Introduce name of the new exercise: ')
                type=input('Introduce type of exercise (cardio or strength): ')
                if type=='cardio':
                    distance=input('Introduce distance(km): ')
                    velocity=input('Introduce velocity: ')
                    resistance=input('Introduce resistance: ')
                    machine= None
                    material= None
                    reps= None
                    sets=None
                    weight=None
                elif type=='strength':
                    distance=None
                    velocity=None
                    resistance=None
                    machine= input('Are you using any machine? (True/False) ')
                    material= input('What material are you using ? ')
                    reps= input('Introduce number of reps: ')
                    sets=input('Introduce number of sets: ')
                    weight=input('Introduce weight that you are using (kg) : ')
                cursor3.callproc('add_exercise',args=[exercise_name,workout_id,type,distance,velocity,resistance,machine,material,reps,sets,weight])
                connection.commit()
                cursor3.close()
                successful_operation=True
            except pymysql.MySQLError as error:
                print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
                print("Please try again.")
        successful_operation=False
        cursor4=connection.cursor()
        while not successful_operation:
            try:
                cursor4.callproc('new_exercise_in_workout', args=[exercise_name,workout_id])
                connection.commit()
                cursor4.close()
                successful_operation=True
            except pymysql.MySQLError as error:
                print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
                print("Please try again.")
        print('Exercise added to workout!')
    else:
        print('Option not valid. Operation aborted')
            

#Function to add workout
def add_workout(connection,user_id):
    successful_operation=False
    cursor1=connection.cursor()
    while not successful_operation:
        try:
            duration=input('Introduce duration of workout (min): ')
            calories_burned=input('Introduce number of calories burned with this workout: ')
            cursor1.callproc('add_workout', args=[user_id,duration,calories_burned])
            connection.commit()
            cursor1.close()
            successful_operation=True
        except pymysql.MySQLError as error:
            print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
            print("Please try again.")
    while True:
        add_exercise=input('Do you want to add an exercise to this workout? (Yes/No) ')
        if add_exercise=='Yes':
            cursor2=connection.cursor()
            sql_stam='select workout_id from workout order by workout_id desc limit 1'
            cursor2.execute(sql_stam)
            workout_id=cursor2.fetchone()
            cursor2.close()
            add_exercise_to_workout(connection,workout_id)
        elif add_exercise=='No':
            print('Workout created successfully!')
            break
        else:
            print('Answer not valid')


#Function to edit workout
def edit_workout(connection):
    successful_operation=False
    cursor1=connection.cursor()
    while not successful_operation:
        try:
            cursor2=connection.cursor()
            sql_stam="select workout_id from workout order by workout_id asc"
            cursor2.execute(sql_stam)
            possible_workout_ids=cursor2.fetchall()
            print('Workout ids: ')
            for w in possible_workout_ids:
                print(w)
            cursor2.close()
            workout_id=input('Introduce id of workout that you want to modify: ')
            duration=input('Introduce new duration of workout (min): ')
            calories_burned=input('Introduce new number of calories burned with this workout: ')
            cursor1.callproc('add_workout', args=[workout_id,duration,calories_burned])
            connection.commit()
            cursor1.close()
            successful_operation=True
        except pymysql.MySQLError as error:
            print(f"Error: {error.args[1]} (SQLSTATE: {error.args[0]})")
            print("Please try again.")
    while True:
        add_exercise=input('Do you want to add an exercise to this workout? (Yes/No) ')
        if add_exercise=='Yes':
            add_exercise_to_workout(connection,workout_id)
        elif add_exercise=='No':
            print('Workout updated successfully!')
            break
        else:
            print('Answer not valid')



#Connection with database:
while True:
    try:
        username=input('Introduce MySQL username: ')
        password=input('Introduce MySQL password: ')
        connection = pymysql.connect(
            host='localhost',  
            user=username,
            password=password,
            database='health_and_fitness_databaseSchema',
            cursorclass=pymysql.cursors.DictCursor ) 
        break
    except pymysql.MySQLError as error:
        print('incorrect credentials')

#Login
while True:
    print('Are you registered?')
    print('1. Yes , login')
    print('2. No , create an account')
    choice=input('Select 1 or 2 ')
    if choice=='1': 
        valid_id=False
        while not valid_id:
            sql_stam= 'SELECT check_valid_id(%d)'
            user_id=input('Introduce user id : ')
            cursor=connection.cursor()
            cursor.execute(sql_stam,user_id)
            valid_id= cursor.fetchone()
            cursor.close()
        break
    elif choice=='2':
        user_id=create_account(connection)
        print('Account created. Your user id is ',user_id)
    else :
        print('No valid option')

#Menu
while True:
    print('1. Add new goal')
    print('2. Track health test')
    print('3. Track meal')
    print('4. Add workout')
    print('5. Edit workout')
    choice=input('Choose one option: ')
    if choice=='1':
        add_new_goal(connection,user_id)
    elif choice=='2':
        track_health_test(connection,user_id)
    elif choice=='3' :
        track_meal(connection,user_id)
    elif choice== '4' :
        add_workout(connection,user_id)
    elif choice== '5' :
        edit_workout(connection,user_id)
    else:
        print('Option not valid')
    follow_execution=input('Do you want to close session? (Yes/No) ')
    while follow_execution!='Yes' or follow_execution!='No':
        print('Answer not valid')
        follow_execution=input('Do you want to close session? (Yes/No) ')
    if follow_execution== 'No':
        connection.close()
        break
    
