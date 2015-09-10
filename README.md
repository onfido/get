# Get

Dynamically generate classes to encapsulate common database queries in Rails.

## Usage

#### Singular Queries - Return a single record

With field being queried in the class name
```ruby
Get::UserById.run(123)
```

Fail loudly
```ruby
Get::UserById.run!(123)
```

Slightly more flexible model:
```ruby
Get::UserBy.run(id: 123, employer_id: 88)
```

#### Plural Queries - Return a collection of records

_Note the plurality of 'Users'_
```ruby
Get::UsersByLastName.run('Turner')
```

With Options
```ruby
Get::UsersByLastName.run('Turner', limit: 10, offset: 20, order: { last_name: :desc })
```

All records
```ruby
Get::AllUsers.run
```

#### Associations

Associations use 'From', and are sugar for the chains we so often write in rails.

_You can pass either an entity or an id, the only requirement is that it responds to #id_

Parent relationship (user.employer):
```ruby
Get::EmployerFromUser.run(user)
```

Child relationship (employer.users):
```ruby
Get::UsersFromEmployer.run(employer_id)
```

Complex relationship (user.employer.sportscars)
```ruby
Get::SportscarsFromUser.run(user, via: :employer)
```

Eager Loading
```ruby
Get::SportscarsFromUser.run(user, via: :employer, eager_load: true)
```

Query Associations
```ruby
Get::SportscarsFromUser.run(user, via: :employer, conditions: { make: 'Audi' }, limit: 10, offset: 20)
```

Keep the plurality of associations in mind. If an Employer has many Users, UsersFromEmployer works,
but UserFromEmployer will throw `Get::Errors::InvalidAncestry`.

## Joins

Associations use 'JoinedWith', and make the dark world of joins much more palatable.
Joins will always return a Horza::Collection.

*It is recommended to pass a fields hash when using Get joins.
If you do not, your database implementation will decide which values are placed in fields with common names, like :id.*

Join on related ids, select multiple fields
```ruby
join_params = {
  on: { employer_id: :id }, # base_table(users).employer_id = join_table(employers).id
  fields: {
    users: [:first_name, :last_name],
    employers: [:address],
  }
}
Get::UsersJoinedWithEmployers.run(join_params)
```

Join on related ids, select multiple fields - with conditions, limit, and offset
```ruby
join_params = {
  on: { employer_id: :id }, # base_table(users).employer_id = join_table(employers).id
  fields: {
    users: [:first_name, :last_name],
    employers: [:address],
  },
  conditions: {
    users: { last_name: 'Turner' },
    employers: { company_name: 'Corporation ltd.' }
  },
  limit: 10,
  offset: 5
}
Get::UsersJoinedWithEmployers.run(join_params)
```

Join on multiple requirements, alias field names
```ruby
join_params = {
  on: [
    { employer_id: :id }, # base_table(users).employer_id = join_table(employers).id
    { email: :email }, # base_table(users).email = join_table(employers).email
  ],
  fields: {
    users: [:id, { first_name: :my_alias_for_first_name }],
    employers: [:email, { id: :my_alias_for_employer_id }]
  }
}
Get::UsersJoinedWithEmployers.run(join_params)
```

## Options

**Base Options**

Key | Type | Details
--- | ---- | -------
`order` | Hash | { `field` => `:asc`/`:desc` }
`limit` | Integer | Number of records to return
`offset` | Integer | Number of records to offset
`id` | Integer | The id of the root object (associations only)
`target` | Symbol | The target of the association - ie. employer.users would have a target of :users (associations only)
`eager_load` | Boolean | Whether to eager_load the association (associations only)

**Association Options**

Key | Type | Details
--- | ---- | -------
`conditions` | Hash | Key value pairs for the query
`eager_load` | Boolean | Whether to eager_load the association
`via` | [Symbol] | The associations that need to be traversed in order to reach the desired record(s). These must be in the correct order, ie user.employer.parent.children would be Get::ChildrenFromUser.run(user_id, via: [:employer, :parent]). You can also pass a single symbol instead of an array of length 1.

**Join Options**

Key | Type | Details
--- | ---- | -------
`on` | Hash or Array of Hashes | Key value pairs representing base_table field => join_table field
`fields` | Hash | Keys are the table names, values are array of field names or hashes defining the field's alias for the join. See examples above.
`conditions` | Hash | Keys are the table names, values are Key value pairs for the query. See examples above.

## Why is this necessary?

#### Problem 1: Encapsulation

ORMs like ActiveRecord make querying the database incredible easy, but with power comes responsibility, and there's a lot of irresponsible code out there.

Consider:

```ruby
User.where(name: 'blake').order('updated_at DESC').limit(2)
```

This query is easy to read, and it works. Unfortunately, anything that uses it is tough to test, and any other implementation has to repeat this same cumbersome method chain.
Sure, you can wrap it in a method:

```ruby
def find_two_blakes
  User.where(name: 'blake').order('updated_at DESC').limit(2)
end
```

But where does it live? Scope methods on models are (IMHO) hideous, so maybe a Helper? A Service? A private method in a class that I inherit from? The options aren't great.

#### Problem 2: Associations

ORMs like ActiveRecord also makes querying associations incredible easy. Consider:

```html+ruby
<div>
  <ul>
    <% current_user.employer.sportscars.each do |car| %>
      <li><%= car.cost %></li>
    <% end >
  </ul>
</div>
```

The above is a great example of query pollution in the view layer. It's quick-to-build, tough-to-test, and very common in Rails.
A spec for a view like this would need to either create/stub each of the records with the proper associations, or stub the entire method chain.

If you move the query to the controller, it's a bit better:

```ruby
# controller
def index
  @employer = current_user.employer
  @sportscars = @employer.sportscars
end
```

```html+ruby
#view
<div>
  <ul>
    <% @sportscars.each do |car| %>
      <li><%= car.cost %></li>
    <% end >
  </ul>
</div>
```

But that's just lipstick on a pig. We've simply shifted the testing burden to the controller; the dependencies and mocking complexity remain the same.

#### Problem 3: Self-Documenting code

Consider:

```ruby
User.where(last_name: 'Turner').order('id DESC').limit(1)
```

Most programmers familiar with Rails will be able to understand the above immediately, but only because they've written similar chains a hundred times.

## Solution

The Get library tries to solve the above problems by dynamically generating classes that perform common database queries.
Get identifies four themes in common queries:

- **Singular**: Queries that expect a single record in response
- **Plural**: Queries that expect a collection of records in response
- **Query**: Query is performed on the given model
- **Association**: Query traverses the associations of the given model and returns a different model

These themes are not mutually exclusive; **Query** and **Association** can be either **Singular** or **Plural**.

## Entities

Ironically, one of the "features" of Get is its removal of the ability to query associations from the ORM response object.
This choice was made to combat query pollution throughout the app, particularly in the view layer.

To achieve this, Get returns Horza Entities instead of ORM  objects (`ActiveRecord::Base`, etc.).
See the [Horza Readme](https://github.com/onfido/horza) for instructions on how to create your own entities.

Individual entities will have all attributes accessible via dot notation and hash notation, but attempts to get associations will fail.
Collections have all of the common enumerator methods: `first`, `last`, `each`, and `[]`.

## Testing

A big motivation for this library is to make testing database queries easier.
Get accomplishes this by making class-level mocking/stubbing very easy.

Consider:

```ruby
# sportscars_controller.rb

# ActiveRecord
def index
  @sportscars = current_user.employer.sportscars
end

# Get
def index
  @sportscars = Get::SportscarsFromUser.run(current_user, via: employer)
end
```

The above methods do pretty much the exact same thing (the only difference is that the second example returns a Horza Entity instead of an ORM object). Cool, let's test them:

```ruby
# sportscars_controller.rb
describe SportscarsController, type: :controller do
  context '#index' do
    context 'ActiveRecord' do
      let(:user) { FactoryGirl.build_stubbed(:user, employer: employer) }
      let(:employer) { FactoryGirl.build_stubbed(:employer) }
      let(:sportscars) { 3.times { FactoryGirl.build_stubbed(:sportscars) } }

      before do
        employer.sportscars << sportscars
        sign_in(user)
        get :index
      end

      it 'assigns sportscars' do
        expect(assigns(:sportscars)).to eq(sportscars)
      end
    end

    context 'Get' do
      let(:user) { FactoryGirl.build_stubbed(:user, employer: employer) }
      let(:sportscars) { 3.times { Horza::Entities::Single.new(FactoryGirl.attributes_for(:sportscars)) } }

      before do
        allow(Get::SportscarsFromUser).to receive(:run).and_return(sportscars)
        sign_in(user)
        get :index
      end

      it 'assigns sportscars' do
        expect(assigns(:sportscars)).to eq(sportscars)
      end
    end
  end
end
```

By encapsulating the query in a class, we're able to stub it at the class level, which eliminates then need to create any dependencies.
This will speed up tests (a little), but more importantly it makes them easier to read and write.

## Config

**Define your adapter**

_config/initializers/get.rb_
```ruby
Get.configure { |config| config.adapter = :active_record }
```
You can reset the config at any time using `Get.reset`.

## Adapters

Get currently works with ActiveRecord.

## Edge Cases

**Attributes containing 'By'**

Some attributes contain the word 'by', ie. `Customer.invited_by`.
Because of the way Get parses classnames, you won't be able to use the attribute-specific format.
Use the more general form instead.

```ruby
Get::CustomerByInvitedBy.run('John') #=> throws Get::Errors::InvalidClassName
Get::CustomerBy.run(invited_by: 'John') #=> will work
```

**Models ending with double 's'**

Some models end with a double 's', ie `Address`, `Business`. Rails has a well documented inability to properly inflect this type of word.
There is a simple fix:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular(/ess$/i, 'ess')
end
```

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
