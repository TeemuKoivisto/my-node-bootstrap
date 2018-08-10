export interface IUser {
  name: string
  email: string
}

export interface IUserInternal {
  name: string
  email: string
  privileges: string
  password: string
}

export interface ILoginCredentials {
  email: string
  password: string
}
