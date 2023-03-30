final String engineerUser = '{"submodel": "engineer", "user": {'
    '"id": 1, "email": "bla@bla.com", "username": "bla", "full_name": "", "first_name": "", "last_name": "",'
    '"engineer": {"address": "", "postal": "", "city":"", "country_code": "NL", "mobile": "", "prefered_location": 1}'
    '}}';

final String assignedOrderMaterial = '{"id": 1, "assignedOrderId": 1, "material": 1, "location": 1, "amount": 3.00}';

final String memberPictures = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [{"name": "bla", "picture": "bla.jpg"}]}';

final String assignedOrderActivity = '{"id":129,"assigned_order":309,"work_start":"10:40:00",'
    '"work_end":"16:50:00","travel_to":"01:05:00","travel_back":"02:25:00",'
    '"distance_to":25,"distance_back":50,"activity_date":"18/01/2023","extra_work":"00:35:00",'
    '"extra_work_description":"Test","distance_fixed_rate_amount":0,"actual_work":"06:00:00"}';

final String assignedOrderDocument = '{"id": 1, "assigned_order": 1, "name": "grappig.png", "description": "", "document": "grappig.png"}';

final String orderDocument = '{"id": 1, "order": 1, "name": "grappig.png", "description": "", "document": "grappig.png"}';

final String assignedOrder = '{"id": 1, "engineer_id": 1, "order": {"id": 1, '
    '"uuid": "38b41c8c-0f9e-401e-b341-80985852a210", "customer_id": "1234", "order_id": "m1_order_id1", '
    '"service_number": null, "order_reference": null, "order_type": "test", "customer_remarks": null, '
    '"description": null, "start_date": "28/03/2023", "start_time": null, "end_date": "28/03/2023",'
    ' "end_time": null, "order_date": "28/03/2023", "last_status": "no status found", "last_status_full": '
    '"no status found", "remarks": null, "order_name": "test", "order_address": "test 1",'
    ' "order_postal": "1234AA", "order_city": "bla", "order_country_code": "NL", "order_tel": "0612345678",'
    ' "order_mobile": "0612345678", "order_email": "bla@bla.com", "order_contact": "henk", "created": "28/03/2023 09:39", '
    '"documents": [], "orderlines": [], "workorder_pdf_url": "", "total_price_purchase": "0.00", '
    '"total_price_selling": "0.00", "customer_relation": null, "customer_rate_avg": "-", '
    '"required_assigned": "1/1 (100.00%)", "required_users": 1, "user_order_available_set_count": 0, '
    '"assigned_count": 1, "workorder_url": "https://companycode1.my24service.com:8000/#/orders/orders/workorder/38b41c8c-0f9e-401e-b341-80985852a210",'
    ' "workorder_pdf_url_partner": "", "customer_order_accepted": true, "workorder_documents": [],'
    ' "infolines": [], "statusses": [], "maintenance_product_lines": [], "branch": null}, "is_started": false,'
    ' "is_ended": false, "is_signed": false,'
    ' "start_codes": [{"id": 1, "statuscode": "Start", "description": "Start"}],'
    ' "end_codes": [{"id": 2, "statuscode": "End", "description": "End"}], "after_end_order_codes": [], '
    '"assigned_userdata": [{"full_name": "bla", "date": "28/03/2023", "mobile": "None"}], '
    '"after_end_reports": [], "customer": {}, "assignedorder_date": "28/03/2023"}';

final String order = '{"id":506,"uuid":"f194abef-04dc-4874-ac79-38b6c1204849","customer_id":"1263","order_id":"10603","service_number":null,'
    '"order_reference":"","order_type":"Onderhoud","customer_remarks":"","description":null,"start_date":"17/03/2023","start_time":null,'
    '"end_date":"17/03/2023","end_time":null,"order_date":"17/03/2023","last_status":"Workorder signed",'
    '"last_status_full":"17/03/2023 11:52 Workorder signed","remarks":null,"order_name":"Fictie B.V.","order_address":"Metaalweg 4",'
    '"order_postal":"3751LS","order_city":"Bunschoten-Spakenburg","order_country_code":"NL","order_tel":"0650008","order_mobile":"+31610344871",'
    '"order_email":null,"order_contact":"L. Welling","created":"15/03/2023 11:44","documents":[],"statusses":[{"id":1590,"order":506,'
    '"status":"Aangemaakt door planning","modified":"15/03/2023 11:44","created":"15/03/2023 11:44"},{"id":1594,"order":506,'
    '"status":"Opdracht toegewezen aan mv","modified":"17/03/2023 11:40","created":"17/03/2023 11:40"},{"id":1595,"order":506,'
    '"status":"Begin opdracht gemeld door mv","modified":"17/03/2023 11:40","created":"17/03/2023 11:40"},{"id":1596,"order":506,'
    '"status":"Opdracht klaar gemeld door mv","modified":"17/03/2023 11:43","created":"17/03/2023 11:43"},{"id":1597,"order":506,'
    '"status":"Workorder signed","modified":"17/03/2023 11:52","created":"17/03/2023 11:52"}],"orderlines":[{"id":1311,"product":"df",'
    '"location":"df","remarks":"df","price_purchase":"0.00","price_selling":"0.00","amount":0,"material_relation":null,'
    '"location_relation_inventory":null,"purchase_order_material":null}],'
    '"workorder_pdf_url":"https://demo.my24service-dev.com/media/workorders/demo/workorder-demo-10603.pdf","total_price_purchase":"0.00",'
    '"total_price_selling":"0.00","customer_relation":1167,"customer_rate_avg":null,"required_assigned":"1/1 (100.00%)","required_users":1,'
    '"user_order_available_set_count":0,"assigned_count":1,'
    '"workorder_url":"https://demo.my24service-dev.com/#/orders/orders/workorder/f194abef-04dc-4874-ac79-38b6c1204849",'
    '"workorder_pdf_url_partner":"","customer_order_accepted":true,"workorder_documents":[],"workorder_documents_partners":[],'
    '"infolines":[{"id":66,"info":"sd"}],"assigned_user_info":[{"full_name":"Melissa Vedder","license_plate":""}],'
    '"maintenance_product_lines":[],"reported_codes_extra_data":[],"branch":null}';

final String orderTypes = '["Storing","Reparatie","Onderhoud","Klein onderhoud","Groot onderhoud","2 verdiepingen","Trap mal"]';

final String customerHistoryOrder = '{"id": 2,'
    ' "order_id": "CjyRbcAwpVpbdJhsgSiayEWQdxRYkLWRJtuIjwJfJpwcDuEFoRaNRkqHqUuN", "order_date": "30/03/2023", "order_type": '
    '"test", "order_reference": "123456", "workorder_pdf_url": "", "workorder_pdf_url_partner": "", "last_status": "Workorder signed", '
    '"last_status_full": "17/03/2023 11:52 Workorder signed", "orderlines": [{"id":1311,"product":"df","location":"df","remarks":"df",'
    '"price_purchase":"0.00","price_selling":"0.00","amount":0,"material_relation":null,"location_relation_inventory":null,'
    '"purchase_order_material":null}]}';
