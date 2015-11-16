function hide_signup_password(check_box){
  if(check_box.checked) {
    $('#signup_password').attr('type', 'password');
    $('#user_password_confirmation').attr('type', 'password');
  } else {
    $('#signup_password').attr('type', 'text');
    $('#user_password_confirmation').attr('type', 'text');
  }
}

function hide_login_password(check_box){
  if(check_box.checked) {
    $('#login_password').attr('type', 'password');
  } else {
    $('#login_password').attr('type', 'text');
  }
}
