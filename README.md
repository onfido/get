# Get

Get is a library designed to encapsulate Rails database queries and prevent query pollution in the view layer.

## Why is this necessary?

#### Problem 1: Encapsulation

ORMs like ActiveRecord make querying the database incredible easy, but it's a double-edged sword. Consider:

```
User.where(name: 'blake').order('updated_at DESC').limit(2)
```

It's easy to read, and it works. Unfortunately, anything that uses it is tough to test, and any other implementation has to repeat this same cumbersome method chain.
Sure, you can wrap it in a method:

```
def find_blakes
  User.where(name: 'blake').order('updated_at DESC').limit(2)
end
```

But where does it live? Scoped methods on models are (IMHO) hideous, so maybe a Helper? A Service? A private method in a class that I inherit from? The options aren't great.

#### Problem 2: Associations

ActiveRecord also makes querying associations incredible easy, which is also a double-edged sword. Consider:

```
<div>
  <ul>
    <% current_user.employer.sportscars.each do |car| %>
      <li><%= title %></li>
    <% end >
  </ul>
</div>
```

The above is a great example of quick-to-build/tough-to-test views that are so common in Rails.
Any spec for a view like this would need to create each of the records with the proper associations.

If you move the query to the controller, it's a bit better:

```
# controller
def index
  @employer = current_user.employer
  @sportscars = @employer.sportscars
end

#view
<div>
  <ul>
    <% @sportscars.each do |car| %>
      <li><%= title %></li>
    <% end >
  </ul>
</div>
```

But that's just lipstick on a pig. We've only shifted the testing burden to the controller; in the end, dependencies remain the same.

## Solution

The Get library dynamically generates classes that encapsulate **common** database queries.

## Usage

#### Return a single record

With field being queried in the class name
```
Get::UserById.run(123)
```

Slightly more flexible model:
```
Get::UserBy.run(id: 123, employer_id: 88)
```

#### Return a collection of records

_Note the plurality of 'Users'_
```
Get::UsersByLastName.run('Turner')
```

#### Return an association

Associations use 'From', and are sugar for the chains we so often write in rails.

_You can pass either an entity or an id, the only requirement is that it responds to #id_
Parent relationship (user.employer):
```
Get::EmployerFromUser.run(user)
```

Child relationship (employer.users):
```
Get::UsersFromEmployer.run(employer_id)
```

Complex relationship (information_request.applicant.occupation)
```
Get::OccupationFromInformationRequest.run(information_request, via: :applicant)
```

Keep the nature of associations in mind. If an Employer has many Users, UsersFromEmployer works, but UserFromEmployer will blow up.

## Entities

To combat query pollution, the Get library returns **entities** instead of ActiveModel classes.
These entity classes are generated at runtime with names appropriate to their function.

```
>> result = Get::UserById.run(user.id)
>> result.class.name
>>"Get::Entities::GetUser"
```

Individual records will have all attributes accessible via dot notation and hash notation, but attempts to get associations will fail.
Collections have all of the common enumerator methods: `first`, `last`, `each`, and `[]`.

Dynamically generated Get::Entities are prefixed with `Get` to avoid colliding with your ORM objects.
You can also register your own adapters in the Get config.

## Config

**Define your adapter**

_config/initializers/ask.rb_
```
Get.configure { |config| config.adapter = :active_record }
```

**Configure custom entities**

The code below will cause Get classes that begin with _Users_ (ie. `UsersByLastName`) to return a MyCustomEntity instead of the default `Get::Entities::User`.

_config/initializers/ask.rb_
```
class MyCustomEntity < Get::Entities::Collection
 def east_london_length
   "#{length}, bruv"
 end
end

Get.config do |config|
 config.register_entity(:users, MyCustomEntity)
end
```

You can reset the config at any time using ```Get.reset```.

## Adapters

Get currently works with ActiveRecord.

## Benchmarking

Get requests generally run < 1ms slower than ActiveRecord requests.

```
GETTING BY ID, SAMPLE_SIZE: 400


>>> ActiveRecord
                                     user     system      total        real
Clients::User.find               0.170000   0.020000   0.190000 (  0.224373)
Clients::User.find_by_id         0.240000   0.010000   0.250000 (  0.342278)

>>> Get
                                     user     system      total        real
Get::UserById                    0.300000   0.020000   0.320000 (  0.402454)
Get::UserBy                      0.260000   0.010000   0.270000 (  0.350982)


GETTING SINGLE RECORD BY LAST NAME, SAMPLE_SIZE: 400


>>> ActiveRecord
                                     user     system      total        real
Clients::User.where              0.190000   0.020000   0.210000 (  0.292516)
Clients::User.find_by_last_name  0.180000   0.010000   0.190000 (  0.270033)

>>> Get
                                     user     system      total        real
Get::UserByLastName              0.240000   0.010000   0.250000 (  0.337908)
Get::UserBy                      0.310000   0.020000   0.330000 (  0.415142)


GETTING MULTIPLE RECORDS BY LAST NAME, SAMPLE_SIZE: 400


>>> ActiveRecord
                                     user     system      total        real
Clients::User.where              0.020000   0.000000   0.020000 (  0.012604)

>>> Get
                                     user     system      total        real
Get::UsersByLastName             0.100000   0.000000   0.100000 (  0.105822)
Get::UsersBy                     0.100000   0.010000   0.110000 (  0.106406)


GETTING PARENT FROM CHILD, SAMPLE_SIZE: 400


>>> ActiveRecord
                                     user     system      total        real
Clients::User.find(:id).employer  0.440000   0.030000   0.470000 (  0.580800)

>>> Get
                                     user     system      total        real
Get::EmployerFromUser            0.500000   0.020000   0.520000 (  0.643316)


GETTING CHILDREN FROM PARENT, SAMPLE_SIZE: 400


>>> ActiveRecord
                                     user     system      total        real
Clients::Employer.find[:id].users  0.160000   0.020000   0.180000 (  0.218710)

>>> Get
                                     user     system      total        real
Get::UsersFromEmployer           0.230000   0.010000   0.240000 (  0.293037)


STATS

AVERAGE DIFF FOR BY ID: 0.000233s
AVERAGE DIFF FOR BY LAST NAME: 0.000238s
AVERAGE DIFF FOR BY LAST NAME (MULTIPLE): 0.000234s
AVERAGE DIFF FOR PARENT FROM CHILD: 0.000156s
AVERAGE DIFF FOR CHILDREN FROM PARENT: -0.000186s
```
