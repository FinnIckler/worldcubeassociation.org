import { signIn } from "next-auth/react";
import { WCA_PROVIDER_ID } from "@/auth.config";
import { Button } from "@chakra-ui/react";

export default function LoginButton() {
  return (
    <Button onClick={() => signIn(WCA_PROVIDER_ID)} colorPalette="blue">
      Sign in
    </Button>
  );
}
