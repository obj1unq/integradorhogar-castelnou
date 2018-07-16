// Nota: 4(cuatro)
//tests: Andan todos, algún pequeño error de responsabilidad 
//1.1) R: hay código duplicado
//1.2) MB
//2.1) R: hay codigo duplicado
//2.2 y 2.3) M No lanza error, mezcla orden con pregunta
//3.1) R (no delega)
//3.2) R (no delega)
//3.3) R (no delega)
//3.4) R (duplica código y delega mal)

class Familia{
	
	var property casa = null
	var property miembros = #{}
	
	method confortPromedio(){
		return self.puntosDeConfort() /  self.cantidadDeHabitantes()
	}
	
	method cantidadDeHabitantes(){
		return miembros.size()
	}
	
	method puntosDeConfort(){
		//TODO: malisima delegacion, no se entiende nada: miembtros.sum({miem=>casa.condofrt(miem)})
		return miembros.sum({miem => casa.habitaciones().sum({habita => habita.ConfortConHabitante(miem)})})	
	}
	
	method familiaAGusto(){
		return self.confortPromedio() > 40 and self.todosAGusto()
	}
	
	method todosAGusto(){
		return miembros.all({miem => miem.seSienteAGusto(self)})
	}
	
}

class Casa{
	
	var property habitaciones = #{}
	
	method habitacionesOcupadas(){
		//TODO: delegar en la habitacion: habitacion.estaVacia()
		return habitaciones.filter({habitacion => habitacion.ocupantes().size() > 0})
	}
	method responsablesDeLaCasa(){
		//TODO: delegar en la habitacionL habitacion.responsable()
		return self.habitacionesOcupadas().map({habitacion => habitacion.ocupantes().max({ocupa => ocupa.edad()})}).asSet()
	}
	
}
class Persona{
	
	var property edad = null
	var property habilidadDeCocina = false	
	
	method esMenorDe4Anios(){
		return edad <= 4
	}
	method adquirirHabilidadDeCocina(){
		habilidadDeCocina = true
	}	
	//TODO: mezcla orden con pregunta
	method CambioHabitacion(habitacionOrigen, habitacionDestino){
		if(habitacionDestino.puedeEntrar(self)){
			self.salirHabitacion(habitacionOrigen)
			self.entrarHabitacion(habitacionDestino)
		 	return habitacionDestino
		}else{
			//TODO: si no puede entrar debería lanzar error
			return habitacionOrigen
		}
	}	
	
	//TODO: delegar en la habitacion, no esta bien modificarle la coleccion desde aca
	method salirHabitacion(habitacionOrigen){
		habitacionOrigen.ocupantes().remove(self)
	}
	//TODO: delegar en la habitacion, no esta bien modificarle la coleccion desde aca	
	method entrarHabitacion(habitacionDestino){
		habitacionDestino.ocupantes().add(self)
	}
	method puedeEntrarEnUna(familia){
		return familia.casa().habitaciones().any({habitacion => habitacion.puedeEntrar(self)})
	}	
}

class Obsesivo inherits Persona{
	
	//TODO Codigo duplicado! poner en la superclase el self.puedeEntrarEnUna(familia) and
	method seSienteAGusto(familia){
		return self.puedeEntrarEnUna(familia) and familia.casa().habitacionesOcupadas().all({habita => habita.ocupantes().size() <= 2})
	}	
}
class Goloza inherits Persona{
	method seSienteAGusto(familia){
		return self.puedeEntrarEnUna(familia) and familia.miembros().any({miem => miem.habilidadDeCocina()})
	}		
}
class Sencilla inherits Persona{
	method seSienteAGusto(familia){
		return self.puedeEntrarEnUna(familia) and familia.casa().habitaciones().size() > familia.miembros().size()
	}	
}

class Habitacion{
	//variable innecesaria: siempre es 10.
	var property confort = 10
	var property ocupantes = #{}
	
	//TODO: no usar mayuscula para el inicio del metodo
	method ConfortConHabitante(unHabitante){
		return self.confort()
	}
	method puedeEntrar(unHabitante){
		//TODO: acá debería revisar que si la habitacion está vacia puede entrar, es comun a todas las habitaciones
		return true
	}
	
}


class Banio inherits Habitacion{
	
	//TODO: Este algoritmo quedó duplicado en las clases hermanas
	override method ConfortConHabitante(unHabitante){
		return super(unHabitante) + self.calculaConfort(unHabitante)
	}
	
	method calculaConfort(unHabitante){
		if(unHabitante.esMenorDe4Anios()){
		  return 2
		}else{
		  return 4
		}
	}
	
	override method puedeEntrar(unHabitante){
		//todo reemplazar if por expresiones lógicas, esto es self.estaVacio() or self.hayOcuanteMenor()
		if(self.estaVacio()){ //este if quedaría repetido en todas las clases por como lo hiciste
			return true
		}else{
			return ocupantes.any({ocupa => ocupa.esMenorDe4Anios()})		
		}
	}
	
	method estaVacio(){
		return ocupantes.size() == 0
	}
	
}

//TODO: Clase innecesaria! no aporta nada, usar directamente habitacion
class UsoGeneral inherits Habitacion{
	
}

class Dormitorio inherits Habitacion{
	
	var property duenios = #{}
	 
	override method ConfortConHabitante(unHabitante){
		return super(unHabitante) + self.calculaConfort(unHabitante)
	}
	method cantidadDeDuenios() = duenios.size()
	
	method calculaConfort(unHabitante){
		//TODO: código duplicado: self.esDuenio(unHabitante),  pierde la regla de si la habitacion está vacia
	return	if(duenios.contains(unHabitante)){						 
		 return	10/ self.cantidadDeDuenios()// Al menos un duenio existe ya que cumple el if, nunca haria division por 0
		}else{
			0
		}
	}
	
	override method puedeEntrar(unHabitante){
		//TODO: mejorar expresiones lógicas, pierde la regla de si la habitacion está vacia
		return if (self.esDuenio(unHabitante)){
			true
		}
		else{
			 duenios.all({duenio => ocupantes.contains(duenio) })
		 }
		 
	}
	
	method esDuenio(unHabitante){
		return duenios.contains(unHabitante)
	}

}

class Cocina inherits Habitacion{
	
	var property m2 = null
	
	//TODO Codigo duplicado
	override method ConfortConHabitante(unHabitante){
		return super(unHabitante) + self.calculaConfort(unHabitante)
	}
	method calculaConfort(unHabitante){
		if(unHabitante.habilidadDeCocina()){
			return m2*porcentajeDeLasCocinas.tamano()
		}else{
			return 0
		}
	}
	
	override method puedeEntrar(unHabitante){
		//TODO: mejorar expresiones lógicas, pierde la regla de si la habitacion está vacia
		if (unHabitante.habilidadDeCocina()){
			return ocupantes.any({ocupa => not ocupa.habilidadDeCocina()})
		}else{
			return true
		}
	}
	
}

object porcentajeDeLasCocinas{
	
	var property tamano = 0.1
	
}