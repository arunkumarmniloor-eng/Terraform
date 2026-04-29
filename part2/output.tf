output "flask_private_ip" { value = aws_instance.flask_app.private_ip }
output "express_public_ip" { value = aws_instance.express_app.public_ip }

