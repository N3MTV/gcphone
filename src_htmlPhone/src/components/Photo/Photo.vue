<script>
import PhoneAPI from './../../PhoneAPI'
export default {
  created: function () {
    PhoneAPI.takePhoto()
  }
}
</script>
