# My24Service App

Dart/Flutter App for My24Service.com available for Android and iOS.


## Audience

This App is meant for users of the My24Service application. Engineers, sales users, customers, and planning users can do most or all of their work via this App.

### Engineers

This App makes it more easy for engineers to do their work compared to the older web interface.

#### Assigned orders

When logged in as an engineer, the first page that is shown is an overview of all assigned orders for the logged in engineer. Clicking on an order will show an overview of the order, and, when the order has not yet been started, a button will be shown where the engineer can start the order.

Once started, more buttons will be displayed:

* **Customer history** - here the engineer can view the order history for this customer
* **Register time/km** - here the engineer can enter workhours, travel hours, and distance
* **Register materials** - here the engineer can enter used materials
* **Manage documents** - here the engineer can upload document, images or take an image and upload this

The last button is for ending the order. After everything needed is entered using the buttons above, the engineer can use this button to mark the order as finished. When pressed, three more buttons are shown:

* **Extra work** - this will make a copy of this order, meant for cases where there is extra work to be done for this customer but which is not defined in the original order. The new order will be displayed in the order list and can be processed like a normal order
* **Sign workorder** - here the engineer and customer can view an overview of the order and all entered information like workhours, travel hours, distance, etc. When everything is agreed upon, the engineer and customer can sign the workorder and submit it afterwards. The order is then completely finished and will disappear from the order list
* **No workorder** - when pressed, there is no need for a workorder, and the order will be marked completely finished and will disappear from the order list

#### New quotation

Here the engineer can create a new quotation for a customer. It often happens when the engineer is at the customer there's concluded that more work needs to be done, and the customer would like a quotation for this extra work.

The engineer can do this via the form shown on this page. When entering all the data, and pressing "Add quotation", the quotation will be shown in the "Quotations not yet accepted". While the quotation is still in this list (not yet accepted by the planning), the engineer can upload or take pictures attached to the just created quotation.

Not yet accepted quotations can also still be deleted.

#### Quotations not yet accepted

This is the list of all quotations that not yet have been accepted by the planning.

#### Location inventory

In this page the engineer can see what inventory is available for which location. When entering materials when working on an order, the amount for a material is subtracted from the location that is chosen, and changes can be seen here. This is tight to the My24Service Inventory module.

#### Settings

Here the engineer can change some settings in the App.

#### Logout

Here the engineer can logout.

### Sales users

Sales users are users that have access to information about certain customers.

#### Your customers' orders

Here sales users can see all current orders for customers that have been assigned to this user.

#### Quotations

Here sales users can view which quotations have been created for customers that have been assigned to this user.

#### Quotations not yet accepted

Here sales users can view quotations that have been created for customers that have been assigned to this user but not yet have been accepted.

#### Your customers

In this page a list of customers is shown that are assigned to this user. The customer info can be edited, and when, choosing a customer by tapping on it, the order history for this customer is shown.

#### Manage your customers

In this page the sales user can control which customers are assigned to him or her.

#### New customer

In this page a new customer can be created.

#### Settings

Here the sales user can change some settings in the App.

#### Logout

Here the sales user can logout.

### Customers

Customers of the selected company can see past en current orders, enter new ones, and view quotations.

#### Orders

This page shows all current orders for the customer.

#### Orders processing

This page shows newly entered orders by the customer, that are not yet accepted by the companies' planning. After being accepted, the order can not be changed.

#### Past orders

This page shows a list of past orders for this customer.

#### New order

Here the customer can enter new orders. The order has to get accepted by the planning, and will then show up in the order list.

#### Quotations

This page shows a list of all quotations for this customers.

#### Settings

Here the customer can change some settings in the App.

#### Logout

Here the customer can logout.

### Planning

Planning users can manage more than the users mentioned above.

#### Orders

This page shows all current orders.

#### Orders not yet accepted

This page shows newly entered orders by a customer, that are not yet accepted. Planning users can accept these orders here.

#### Orders unassigned

This page shows orders that not yet have been assigned. Planning users can assign these orders to one or more engineers.

#### New order

Here a new order can be created.

#### Customers

This page shows a list of all customers.

#### Quotations

This page shows a list of all quotations.

#### Quotations not yet accepted

This page shows a list of all quotations that have not yet been accepted. Planning users can accept these quotations here.

#### New customer

New customers can be created here.

#### Settings

Here the planning user can change some settings in the App.

#### Logout

Here the planning user can logout.
